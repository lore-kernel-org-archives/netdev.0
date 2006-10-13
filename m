From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] sk98lin: handle pci_enable_device() return value in
 skge_resume() properly
Date: Thu, 12 Oct 2006 17:50:13 -0700
Message-ID: <20061012175013.87564a57.akpm@osdl.org>
References: <Pine.LNX.4.64.0610130002320.29022@twin.jikos.cz>
	<20061012152512.66f147b8@freekitty>
	<Pine.LNX.4.64.0610130028450.29022@twin.jikos.cz>
	<20061012154714.6924f465@freekitty>
	<Pine.LNX.4.64.0610130052440.29022@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, mlindner@syskonnect.de,
	rroesler@syskonnect.de, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751398AbWJMAu2@vger.kernel.org>
To: Jiri Kosina <jikos@jikos.cz>
In-Reply-To: <Pine.LNX.4.64.0610130052440.29022@twin.jikos.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Oct 2006 00:57:18 +0200 (CEST)
Jiri Kosina <jikos@jikos.cz> wrote:

> @@ -5070,7 +5070,13 @@ static int skge_resume(struct pci_dev *p
>  
>  	pci_set_power_state(pdev, PCI_D0);
>  	pci_restore_state(pdev);
> -	pci_enable_device(pdev);
> +	ret = pci_enable_device(pdev);
> +	if (ret) {
> +		printk(KERN_ERR "sk98lin: Cannot enable PCI device %s during resume\n", 
> +				dev->name);
> +		unregister_netdev(dev);

This looks rather wrong - skge_exit() will run unregister_netdev() again.

Look a few lines down, to where this function already handles request_irq()
failure, reuse that code path.  Hopefully it has been tested..

(Once we have an easy-to-use fault-injection framework we'll be able to
test all these things more easily)

(But it's possible to test them already, with a bit of ad-hoc testing code)
