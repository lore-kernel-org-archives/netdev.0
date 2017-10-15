From: Gilad Ben-Yossef <gilad-6S/DczAoZh3WXxRugSxzZg@public.gmane.org>
Subject: [PATCH v9 03/20] net: use -EAGAIN for transient busy indication
Date: Sun, 15 Oct 2017 10:19:48 +0100
Message-ID: <1508059209-25529-4-git-send-email-gilad@benyossef.com>
References: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
Cc: Ofir Drang <ofir.drang-5wv7dgnIgG8@public.gmane.org>, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, linux-fscrypt-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ima-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
        linux-ima-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Tom Lendacky <thomas.lendacky-5C7GfCeVMHo@public.gmane.org>,
        Gary Hook <gary.hook-5C7GfCeVMHo@public.gmane.org>,
        Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
        Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alasdair Kergon <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
        "Theodore Y. Ts'o" <tytso-3s7WtUTddSA@public.gmane.org>,
        Jaegeuk Kim <jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>,
        Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
        Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
        Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Dmitry Kasatkin <dmitry.ka
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1508059209-25529-1-git-send-email-gilad-6S/DczAoZh3WXxRugSxzZg@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace -EBUSY with -EAGAIN when handling transient busy
indication in the absence of backlog.

Signed-off-by: Gilad Ben-Yossef <gilad-6S/DczAoZh3WXxRugSxzZg@public.gmane.org>

---

Please squash this patch with the previous one when merging upstream.

 net/ipv4/ah4.c  | 2 +-
 net/ipv4/esp4.c | 2 +-
 net/ipv6/ah6.c  | 2 +-
 net/ipv6/esp6.c | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 37db44f..049cb0a 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -240,7 +240,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 		if (err == -EINPROGRESS)
 			goto out;
 
-		if (err == -EBUSY)
+		if (err == -EAGAIN)
 			err = NET_XMIT_DROP;
 		goto out_free;
 	}
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b00e4a4..ff8e088 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -432,7 +432,7 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	case -EINPROGRESS:
 		goto error;
 
-	case -EBUSY:
+	case -EAGAIN:
 		err = NET_XMIT_DROP;
 		break;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 7802b72..ba0c145 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -443,7 +443,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 		if (err == -EINPROGRESS)
 			goto out;
 
-		if (err == -EBUSY)
+		if (err == -EAGAIN)
 			err = NET_XMIT_DROP;
 		goto out_free;
 	}
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 89910e2..1a71ee5 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -396,7 +396,7 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 	case -EINPROGRESS:
 		goto error;
 
-	case -EBUSY:
+	case -EAGAIN:
 		err = NET_XMIT_DROP;
 		break;
 
-- 
2.7.4
