From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH] net/s2io: replace schedule_timeout() with msleep()
Date: Wed, 9 Feb 2005 11:29:58 -0800
Message-ID: <200502091930.j19JUmDD002523@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@oss.sgi.com>
In-Reply-To: 
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
Please ignore this, it should not have gone to the list :-)
Leonid

> -----Original Message-----
> From: Leonid Grossman [mailto:leonid.grossman@s2io.com] 
> Sent: Wednesday, February 09, 2005 11:26 AM
> To: 'Ravinandan Arakali'; 'Dmitry Yusupov'
> Cc: 'netdev@oss.sgi.com'
> Subject: FW: [PATCH] net/s2io: replace schedule_timeout() 
> with msleep()
> 
>  Hi guys,
> What is the difference between linux-net@vger.kernel.org and 
> netdev@oss.sgi.com lists?
> How to subscribe for the former?
> 
> Best, Leonid
> 
> -----Original Message-----
> From: Nishanth Aravamudan [mailto:nacc@us.ibm.com]
> Sent: Wednesday, February 09, 2005 11:19 AM
> To: akpm@osdl.org; jgarzik@pobox.com
> Cc: linux-net@vger.kernel.org; Ravinandan Arakali; 
> 'Raghavendra Koushik'; kernel-janitors@lists.osdl.org; 
> leonid.grossman@neterion.com
> Subject: [PATCH] net/s2io: replace schedule_timeout() with msleep()
> 
> On Wed, Feb 09, 2005 at 10:37:59AM -0800, Ravinandan Arakali wrote:
> > Nishanth,
> > We did some basic testing after applying your patch and it 
> seems okay.
> > Pls submit the patch to maintainer. But I've couple of comments on 
> > your patch.
> > The below code change is incorrect. It should be msleep(500).
> > > @@ -3808,8 +3797,7 @@ static int s2io_rldram_test(nic_t * sp, 
> > >  			val64 = readq(&bar0->mc_rldram_test_ctrl);
> > >  			if (val64 & MC_RLDRAM_TEST_DONE)
> > >  				break;
> > > -			set_current_state(TASK_UNINTERRUPTIBLE);
> > > -			schedule_timeout(HZ / 2);
> > > +			msleep(200);
> > 
> > In the function s2io_ethtool_idnic(), call to 
> schedule_timeout() has 
> > not been replaced with msleep(). I've given below the code change I 
> > did before testing.
> > 
> > @@ -3284,11 +3277,10 @@
> >                 sp->id_timer.data = (unsigned long) sp;
> >         }
> >         mod_timer(&sp->id_timer, jiffies);
> > -       set_current_state(TASK_INTERRUPTIBLE);
> >         if (data)
> > -               schedule_timeout(data * HZ);
> > +               msleep(data*1000);
> >         else
> > -               schedule_timeout(MAX_SCHEDULE_TIMEOUT);
> > +               msleep(0xFFFFFFFF);
> >         del_timer_sync(&sp->id_timer);
> > 
> >         if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) {
> 
> Both changes have been committed in the patch below.
> 
> Andrew/Jeff, please consider committing to the networking 
> stack of patches.
> 
> Thanks,
> Nish
> 
> Description: Use msleep() instead of schedule_timeout() to 
> guarantee the task delays as expected. This makes the code 
> independent of HZ values (particularly important when HZ 
> changes or is dynamic). Compile- and boot-tested.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Acked-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
> 
> --- 2.6.11-rc3-v/drivers/net/s2io.c	2005-02-08 
> 17:08:37.000000000 -0800
> +++ 2.6.11-rc3/drivers/net/s2io.c	2005-02-09 
> 11:08:48.000000000 -0800
> @@ -698,8 +698,7 @@ static int init_nic(struct s2io_nic *nic
>  	val64 = 0;
>  	writeq(val64, &bar0->sw_reset);
>  	val64 = readq(&bar0->sw_reset);
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(HZ / 2);
> +	msleep(500);
>  
>  	/*  Enable Receiving broadcasts */
>  	add = &bar0->mac_cfg;
> @@ -952,8 +951,7 @@ static int init_nic(struct s2io_nic *nic
>  				  dev->name);
>  			return -1;
>  		}
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 20);
> +		msleep(50);
>  		time++;
>  	}
>  
> @@ -991,8 +989,7 @@ static int init_nic(struct s2io_nic *nic
>  			return -1;
>  		}
>  		time++;
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 20);
> +		msleep(50);
>  	}
>  
>  	/*
> @@ -1421,8 +1418,7 @@ static int start_nic(struct s2io_nic *ni
>  	SPECIAL_REG_WRITE(val64, &bar0->mc_rldram_mrs, UF);
>  	val64 = readq(&bar0->mc_rldram_mrs);
>  
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(HZ / 10);	/* Delay by around 100 ms. */
> +	msleep(100);			/* Delay by around 100 ms. */
>  
>  	/* Enabling ECC Protection. */
>  	val64 = readq(&bar0->adapter_control); @@ -2437,8 
> +2433,7 @@ int wait_for_cmd_complete(nic_t * sp)
>  			ret = SUCCESS;
>  			break;
>  		}
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 20);
> +		msleep(50);
>  		if (cnt++ > 10)
>  			break;
>  	}
> @@ -2477,15 +2472,13 @@ void s2io_reset(nic_t * sp)
>  	 * As of now I'am just giving a 250ms delay and hoping that the
>  	 * PCI write to sw_reset register is done by this time.
>  	 */
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(HZ / 4);
> +	msleep(250);
>  
>  	/* Restore the PCI state saved during initializarion. */
>  	pci_restore_state(sp->pdev);
>  	s2io_init_pci(sp);
>  
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(HZ / 4);
> +	msleep(250);
>  
>  	/* SXE-002: Configure link and activity LED to turn it off */
>  	subid = sp->pdev->subsystem_device;
> @@ -3298,11 +3291,10 @@ static int s2io_ethtool_idnic(struct net
>  		sp->id_timer.data = (unsigned long) sp;
>  	}
>  	mod_timer(&sp->id_timer, jiffies);
> -	set_current_state(TASK_INTERRUPTIBLE);
>  	if (data)
> -		schedule_timeout(data * HZ);
> +		msleep(data * 1000);
>  	else
> -		schedule_timeout(MAX_SCHEDULE_TIMEOUT);
> +		msleep(0xFFFFFFFF);
>  	del_timer_sync(&sp->id_timer);
>  
>  	if (CARDS_WITH_FAULTY_LINK_INDICATORS(subid)) { @@ 
> -3405,8 +3397,7 @@ static int read_eeprom(nic_t * sp, int o
>  			ret = 0;
>  			break;
>  		}
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 20);
> +		msleep(50);
>  		exit_cnt++;
>  	}
>  
> @@ -3446,8 +3437,7 @@ static int write_eeprom(nic_t * sp, int 
>  				ret = 0;
>  			break;
>  		}
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 20);
> +		msleep(50);
>  		exit_cnt++;
>  	}
>  
> @@ -3703,8 +3693,7 @@ static int s2io_bist_test(nic_t * sp, ui
>  			ret = 0;
>  			break;
>  		}
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 10);
> +		msleep(100);
>  		cnt++;
>  	}
>  
> @@ -3805,8 +3794,7 @@ static int s2io_rldram_test(nic_t * sp, 
>  			val64 = readq(&bar0->mc_rldram_test_ctrl);
>  			if (val64 & MC_RLDRAM_TEST_DONE)
>  				break;
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(HZ / 5);
> +			msleep(200);
>  		}
>  
>  		if (cnt == 5)
> @@ -3822,8 +3810,7 @@ static int s2io_rldram_test(nic_t * sp, 
>  			val64 = readq(&bar0->mc_rldram_test_ctrl);
>  			if (val64 & MC_RLDRAM_TEST_DONE)
>  				break;
> -			set_current_state(TASK_UNINTERRUPTIBLE);
> -			schedule_timeout(HZ / 2);
> +			msleep(500);
>  		}
>  
>  		if (cnt == 5)
> @@ -4183,8 +4170,7 @@ static void s2io_set_link(unsigned long 
>  	 * Allow a small delay for the NICs self initiated 
>  	 * cleanup to complete.
>  	 */
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(HZ / 10);
> +	msleep(100);
>  
>  	val64 = readq(&bar0->adapter_status);
>  	if (verify_xena_quiescence(val64, 
> nic->device_enabled_once)) { @@ -4238,10 +4224,8 @@ static 
> void s2io_card_down(nic_t * sp)
>  	register u64 val64 = 0;
>  
>  	/* If s2io_set_link task is executing, wait till it 
> completes. */
> -	while (test_and_set_bit(0, &(sp->link_state))) {
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 20);
> -	}
> +	while (test_and_set_bit(0, &(sp->link_state)))
> +		msleep(50);
>  	atomic_set(&sp->card_state, CARD_DOWN);
>  
>  	/* disable Tx and Rx traffic on the NIC */ @@ -4257,8 
> +4241,7 @@ static void s2io_card_down(nic_t * sp)
>  			break;
>  		}
>  
> -		set_current_state(TASK_UNINTERRUPTIBLE);
> -		schedule_timeout(HZ / 20);
> +		msleep(50);
>  		cnt++;
>  		if (cnt == 10) {
>  			DBG_PRINT(ERR_DBG,
> 
