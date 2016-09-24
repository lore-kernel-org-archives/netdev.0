From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/6] isdn/eicon: add function declarations
Date: Sat, 24 Sep 2016 10:55:01 +0200
Message-ID: <2111430.P3yaVHAIc2@wuerfel>
References: <1474694204-21563-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:57244 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932321AbcIXIzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 04:55:16 -0400
In-Reply-To: <1474694204-21563-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, September 24, 2016 1:16:44 PM CEST Baoyou Xie wrote:
> We get a few warnings when building kernel with W=1:
> drivers/isdn/hardware/eicon/diddfunc.c:95:12: warning: no previous prototype for 'diddfunc_init' [-Wmissing-prototypes]
> drivers/isdn/hardware/eicon/s_4bri.c:128:6: warning: no previous prototype for 'start_qBri_hardware' [-Wmissing-prototypes]
> drivers/isdn/hardware/eicon/idifunc.c:243:12: warning: no previous prototype for 'idifunc_init' [-Wmissing-prototypes]
> drivers/isdn/hardware/eicon/capifunc.c:217:6: warning: no previous prototype for 'api_remove_complete' [-Wmissing-prototypes]
> ....
> 
> In fact, these functions need be declare in some header files.
> 
> So this patch adds function declarations in
> drivers/isdn/hardware/eicon/di_defs.h,
> drivers/isdn/hardware/eicon/capifunc.h,
> drivers/isdn/hardware/eicon/xdi_adapter.h.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Nice cleanup!

> 
> diff --git a/drivers/isdn/hardware/eicon/capifunc.c b/drivers/isdn/hardware/eicon/capifunc.c
> index 7a0bdbd..869b98e 100644
> --- a/drivers/isdn/hardware/eicon/capifunc.c
> +++ b/drivers/isdn/hardware/eicon/capifunc.c
> @@ -55,9 +55,6 @@ static void diva_release_appl(struct capi_ctr *, __u16);
>  static char *diva_procinfo(struct capi_ctr *);
>  static u16 diva_send_message(struct capi_ctr *,
>  			     diva_os_message_buffer_s *);
> -extern void diva_os_set_controller_struct(struct capi_ctr *);
> -
> -extern void DIVA_DIDD_Read(DESCRIPTOR *, int);
>  
>  /*
>   * debug

There are a couple of other 'extern' declarations in this file,
please do them at all once.

Note that there are also some extern declarations for variables in
this .c files of this driver, so it makes sense to do the variables
and the function declarations at the same time.


> diff --git a/drivers/isdn/hardware/eicon/diva.c b/drivers/isdn/hardware/eicon/diva.c
> index d91dd58..9693add 100644
> --- a/drivers/isdn/hardware/eicon/diva.c
> +++ b/drivers/isdn/hardware/eicon/diva.c
> @@ -28,8 +28,6 @@
>  
>  PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
>  extern IDI_CALL Requests[MAX_ADAPTER];
> -extern int create_adapter_proc(diva_os_xdi_adapter_t *a);
> -extern void remove_adapter_proc(diva_os_xdi_adapter_t *a);

Requests[] is another such example. This is particularly bad,
because the name is extremely generic, and can cause conflicts
when another driver uses the same identifier for a global symbol.

Ideally it should be renamed with to 'diva_requests'.

> --- a/drivers/isdn/hardware/eicon/divasproc.c
> +++ b/drivers/isdn/hardware/eicon/divasproc.c
> @@ -34,8 +34,6 @@
>  
>  
>  extern PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
> -extern void divas_get_version(char *);
> -extern void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf);
>  

same for IoAdapters.

>  static void diva_get_extended_adapter_features(DIVA_CAPI_ADAPTER *a);
> @@ -224,20 +223,10 @@ static void diva_free_dma_descriptor(PLCI *plci, int nr);
>  /* external function prototypes                                     */
>  /*------------------------------------------------------------------*/
>  
> -extern byte MapController(byte);
>  extern byte UnMapController(byte);


The comment "external function prototypes" should be removed along with the
actual prototypes.

>  #define MapId(Id)(((Id) & 0xffffff00L) | MapController((byte)(Id)))
>  #define UnMapId(Id)(((Id) & 0xffffff00L) | UnMapController((byte)(Id)))

and probably the macros can get moved as well for consistency.

> -extern int diva_card_read_xlog(diva_os_xdi_adapter_t *a);
> -
>  /*
>  **  IMPORTS
>  */
> -extern void prepare_pri_functions(PISDN_ADAPTER IoAdapter);
> -extern void prepare_pri2_functions(PISDN_ADAPTER IoAdapter);
> -extern void diva_xdi_display_adapter_features(int card);
> -

Another comment that should go.

	Arnd
