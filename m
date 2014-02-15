From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 10/13] staging: r8188eu: Remove wrapper
 _enter_critical_mutex()
Date: Sat, 15 Feb 2014 12:38:11 -0800
Message-ID: <20140215203811.GA17742@kroah.com>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
 <1392418457-3203-11-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1392418457-3203-11-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 14, 2014 at 04:54:14PM -0600, Larry Finger wrote:
> This wrapper returned the result of mutex_lock_interruptible(); however,
> none of the callers checked the returned value.

Then why is the code logic changing?

> 
> As a result of a gcc upgrade to version 4.8.1, two false unitialized variable
> warnings appeared. To silence the warnings, they are initialized to 0.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 3 ++-
>  drivers/staging/rtl8188eu/hal/usb_ops_linux.c     | 8 +++++---
>  drivers/staging/rtl8188eu/include/osdep_service.h | 9 ---------
>  drivers/staging/rtl8188eu/os_dep/os_intfs.c       | 3 ++-
>  4 files changed, 9 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
> index c197b22..e95a1ba 100644
> --- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
> +++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
> @@ -4429,7 +4429,8 @@ s32 dump_mgntframe_and_wait_ack(struct adapter *padapter, struct xmit_frame *pmg
>  	if (padapter->bSurpriseRemoved || padapter->bDriverStopped)
>  		return -1;
>  
> -	_enter_critical_mutex(&pxmitpriv->ack_tx_mutex, NULL);
> +	if (mutex_lock_interruptible(&pxmitpriv->ack_tx_mutex))
> +		return -1;

That's not what the original code did, so this change could cause
problems, right?

> -static inline int _enter_critical_mutex(struct mutex *pmutex,
> -					unsigned long *pirqL)
> -{
> -	int ret;
> -
> -	ret = mutex_lock_interruptible(pmutex);
> -	return ret;
> -}

This didn't affect the caller function's code path...

I've applied this series up to here.

thanks,

greg k-h
