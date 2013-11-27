From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net] be2net: call napi_disable() for all event queues
Date: Wed, 27 Nov 2013 05:28:02 +0000
Message-ID: <f158e8ac-98d2-4be4-b801-20a18912d672@CMEXHTCAS1.ad.emulex.com>
References: <1385484881-25715-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:9230 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728Ab3K0F2G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 00:28:06 -0500
In-Reply-To: <1385484881-25715-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> 
> The recent be2net commit 6384a4d (adds a support for busy polling)
> introduces a regression that results in kernel crash. It incorrectly
> modified be_close() so napi_disable() is called only for the first queue.
> This breaks a correct pairing of napi_enable/_disable for the rest
> of event queues and causes a crash in subsequent be_open() call.
> 
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index 78a0e85..0aec4d2 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -2663,8 +2663,8 @@ static int be_close(struct net_device *netdev)
>  			napi_disable(&eqo->napi);
>  			be_disable_busy_poll(eqo);
>  		}
> -		adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
>  	}
> +	adapter->flags &= ~BE_FLAGS_NAPI_ENABLED;
> 

Ivan, Thanks for spotting this.
Your fix is correct but it'll be nice if the for-loop for napi_disable
is not even entered when FLAGS_NAPI_ENABLED is not set, as in:

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 603b662..40d2adb 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2658,8 +2658,8 @@ static int be_close(struct net_device *netdev)
 
 	be_roce_dev_close(adapter);
 
-	for_all_evt_queues(adapter, eqo, i) {
-		if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
+	if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
+		for_all_evt_queues(adapter, eqo, i) {
 			napi_disable(&eqo->napi);
 			be_disable_busy_poll(eqo);
 		}

Could you also add the following line to your patch as it fixes a
regression caused by an older be2net commit:
Fixes: 6384a4d0dcf9 ("be2net: add support for ndo_busy_poll")

-Sathya
