From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 1/3] r8169: non-NAPI netif_poll_disable removal
Date: Sat, 6 Nov 2004 09:30:27 +0000
Message-ID: <200411060930.27106.jdmason@us.ibm.com>
References: <200411021203.17013.jdmason@us.ibm.com> <20041106145618.GA4895@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041106145618.GA4895@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 06 November 2004 02:56 pm, Francois Romieu wrote:
[...]
> Yep but it seems to me that there is still a window for a race with NAPI
> if the relevant error path is taken:
>
> 1 - Tx timeout
> 2 - rtl8169_reset_task: netif_poll_disable is issued. Assume that the
>     refilling of the Rx buffers fails -> rtl8169_reset_task schedules
>     itself for later
> 3 - operator closes the device: netif_running(dev) == 0 and rtl8169_close()
>     is issued
> 4 - rtl8169_close() loops on netif_poll_disable()

There is an overall problem with the rtl8169_reset_task.  While the driver 
continues to receive packets, can't allcate any new rx buffers, or the rx dma 
engine is hung and no rx buffers are processed, the rtl8169_reset_task will 
schedule itself and loop forever (as dirty_rx != cur_rx).

It seems to me a better idea to just remove the dirty_rx == cur_rx check, and 
let the function clean-up the mess the driver/adapter is in.  
