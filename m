From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v3 net-next 3/4] filter: add ANC_PAY_OFFSET instruction for loading payload start offset
Date: Tue, 19 Mar 2013 17:39:31 +0100
Message-ID: <1363711172-9728-4-git-send-email-dborkman@redhat.com>
References: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933187Ab3CSQjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:39:40 -0400
In-Reply-To: <1363711172-9728-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is very useful to do dynamic truncation of packets. In particular,
we're interested to push the necessary header bytes to the user space and
cut off user payload that should probably not be transferred for some reasons
(e.g. privacy, speed, or others). With the ancillary extension PAY_OFFSET,
we can load it into the accumulator, and return it. E.g. in bpfc syntax ...

        ld #poff        ; { 0x20, 0, 0, 0xfffff034 },
        ret a           ; { 0x16, 0, 0, 0x00000000 },

... as a filter will accomplish this without having to do a big hackery in
a BPF filter itself. Follow-up JIT implementations are welcome.

Thanks to Eric Dumazet for suggesting and discussing this during the
Netfilter Workshop in Copenhagen.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/filter.h      | 1 +
 include/uapi/linux/filter.h | 3 ++-
 net/core/filter.c           | 5 +++++
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index c45eabc..d2059cb 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -126,6 +126,7 @@ enum {
 	BPF_S_ANC_SECCOMP_LD_W,
 	BPF_S_ANC_VLAN_TAG,
 	BPF_S_ANC_VLAN_TAG_PRESENT,
+	BPF_S_ANC_PAY_OFFSET,
 };
 
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 9cfde69..8eb9cca 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -129,7 +129,8 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define SKF_AD_ALU_XOR_X	40
 #define SKF_AD_VLAN_TAG	44
 #define SKF_AD_VLAN_TAG_PRESENT 48
-#define SKF_AD_MAX	52
+#define SKF_AD_PAY_OFFSET	52
+#define SKF_AD_MAX	56
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 2e20b55..dad2a17 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -348,6 +348,9 @@ load_b:
 		case BPF_S_ANC_VLAN_TAG_PRESENT:
 			A = !!vlan_tx_tag_present(skb);
 			continue;
+		case BPF_S_ANC_PAY_OFFSET:
+			A = __skb_get_poff(skb);
+			continue;
 		case BPF_S_ANC_NLATTR: {
 			struct nlattr *nla;
 
@@ -612,6 +615,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(ALU_XOR_X);
 			ANCILLARY(VLAN_TAG);
 			ANCILLARY(VLAN_TAG_PRESENT);
+			ANCILLARY(PAY_OFFSET);
 			}
 
 			/* ancillary operation unknown or unsupported */
@@ -814,6 +818,7 @@ static void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 		[BPF_S_ANC_SECCOMP_LD_W] = BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_VLAN_TAG]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_ANC_VLAN_TAG_PRESENT] = BPF_LD|BPF_B|BPF_ABS,
+		[BPF_S_ANC_PAY_OFFSET]	= BPF_LD|BPF_B|BPF_ABS,
 		[BPF_S_LD_W_LEN]	= BPF_LD|BPF_W|BPF_LEN,
 		[BPF_S_LD_W_IND]	= BPF_LD|BPF_W|BPF_IND,
 		[BPF_S_LD_H_IND]	= BPF_LD|BPF_H|BPF_IND,
-- 
1.7.11.7
