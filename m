From: "Hante Meuleman" <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH] brcmfmac: fix possible memory leak
Date: Fri, 15 Nov 2013 12:13:37 +0000
Message-ID: <F51492713EF10846800D8C0ED37A7DCE0186947A@SJEXCHMB15.corp.ad.broadcom.com>
References: <1384516475-26589-1-git-send-email-geyslan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Brett Rudley" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Arend Van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Pieter-Paul Giesberts" <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Piotr Haber" <phaber-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	brcm80211-dev-list <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Geyslan G. Bem" <geyslan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384516475-26589-1-git-send-email-geyslan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Good find, wrong solution. The chanspecs is a temporarily variable which should be freed when exiting the function. Not only when there is an error. I personally would have preferred just a  free at the end of the " if (request->n_channels) {". So something like this:

		}
		err = brcmf_p2p_escan(p2p, num_nodfs, chanspecs, search_state,
				      action, P2PAPI_BSSCFG_DEVICE);
+		kfree(chanspecs);
	}

In this case the pointer doesn't have to be initialized to NULL.


Regards,
Hante

-----Original Message-----
From: Geyslan G. Bem [mailto:geyslan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org] 
Sent: vrijdag 15 november 2013 12:54
To: geyslan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: Brett Rudley; Arend Van Spriel; Franky Lin; Hante Meuleman; John W. Linville; Pieter-Paul Giesberts; Piotr Haber; linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; brcm80211-dev-list; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: [PATCH] brcmfmac: fix possible memory leak

In case of error free 'chanspecs'.

Signed-off-by: Geyslan G. Bem <geyslan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index d7a9745..aea2c2e 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -771,7 +771,7 @@ static s32 brcmf_p2p_run_escan(struct brcmf_cfg80211_info *cfg,
 	struct brcmf_cfg80211_vif *vif;
 	struct net_device *dev = NULL;
 	int i, num_nodfs = 0;
-	u16 *chanspecs;
+	u16 *chanspecs = NULL;
 
 	brcmf_dbg(TRACE, "enter\n");
 
@@ -825,8 +825,10 @@ static s32 brcmf_p2p_run_escan(struct brcmf_cfg80211_info *cfg,
 				      action, P2PAPI_BSSCFG_DEVICE);
 	}
 exit:
-	if (err)
+	if (err) {
 		brcmf_err("error (%d)\n", err);
+		kfree(chanspecs);
+	}
 	return err;
 }
 
-- 
1.8.4.2



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
