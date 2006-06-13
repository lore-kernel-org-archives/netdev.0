From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: suspend / resume fix
Date: Tue, 13 Jun 2006 01:00:36 -0400
Message-ID: <448E4674.8010605@pobox.com>
References: <Pine.LNX.4.64.0606102234110.5498@g5.osdl.org>	<448C0F04.9070406@osdl.org>	<Pine.LNX.4.64.0606121032430.5498@g5.osdl.org>	<Pine.LNX.4.64.0606121107460.5498@g5.osdl.org>	<Pine.LNX.4.64.0606121117550.5498@g5.osdl.org>	<20060612222740.GB5783@shell0.pdx.osdl.net>	<Pine.LNX.4.64.0606121537420.5498@g5.osdl.org> <20060613134552.331377c3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20355 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1752299AbWFMFAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 01:00:40 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060613134552.331377c3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> @@ -2183,9 +2190,6 @@ static int sky2_poll(struct net_device *
>  	int work_done = 0;
>  	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
>  
> -	if (!~status)
> -		return 0;
> -
>  	if (status & Y2_IS_HW_ERR)
>  		sky2_hw_intr(hw);
>  

It's probably better to do "goto end_of_function" than simply return, 
but I disagree that this check should be removed.

As long as you are reading values from the hardware, you should include 
this 0xffffffff check.  It's certainly possible that the controller 
could have been unplugged from the time the interrupt handler last ran, 
and the time that NAPI poll runs.


> @@ -3427,9 +3429,14 @@ static void __devexit sky2_remove(struct
>  static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
>  {
>  	struct sky2_hw *hw = pci_get_drvdata(pdev);
> -	int i;
> +	int i, err;
> +	u32 imask;
> +
> +	pci_save_state(pdev);
>  
> -	for (i = 0; i < 2; i++) {
> +	del_timer_sync(&hw->idle_timer);

It would seem smarter to put the timer removal before pci-save-state.


> +	for (i = 0; i < hw->ports; i++) {
>  		struct net_device *dev = hw->dev[i];
>  
>  		if (dev) {
> @@ -3441,8 +3448,17 @@ static int sky2_suspend(struct pci_dev *
>  		}
>  	}
>  
> -	pci_save_state(pdev);
> -	return sky2_set_power_state(hw, pci_choose_state(pdev, state));
> +	imask = sky2_read32(hw, B0_IMSK);
> +	sky2_write32(hw, B0_IMSK, 0);
> +	synchronize_irq(hw->pdev->irq);

This seems "obviously racy" to me.


> +	err = sky2_set_power_state(hw, pci_choose_state(pdev, state));
> +	if (err) {
> +		sky2_write32(hw, B0_IMSK, imask);
> +		sky2_idle_start(hw);
> +	}
> +
> +	return err;
>  }
>  
>  static int sky2_resume(struct pci_dev *pdev)
> @@ -3460,7 +3476,7 @@ static int sky2_resume(struct pci_dev *p
>  	if (err)
>  		goto out;
>  
> -	for (i = 0; i < 2; i++) {
> +	for (i = 0; i < hw->ports; i++) {
>  		struct net_device *dev = hw->dev[i];
>  		if (dev && netif_running(dev)) {
>  			netif_device_attach(dev);
> @@ -3473,7 +3489,10 @@ static int sky2_resume(struct pci_dev *p
>  			}
>  		}
>  	}
> -out:
> +
> +	sky2_idle_start(hw);
> +
> + out:
>  	return err;
>  }
>  #endif
> 
> 

