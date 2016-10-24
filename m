From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: slab-out-of-bounds in sctp_sf_ootb
Date: Mon, 24 Oct 2016 17:44:22 -0200
Message-ID: <20161024194422.GF2958@localhost.localdomain>
References: <CAAeHK+xqO0gVjOMMLUksUF7oaQgzE+vr5cdUJa1Oa0r89FM7eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+xqO0gVjOMMLUksUF7oaQgzE+vr5cdUJa1Oa0r89FM7eQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrey,

On Mon, Oct 24, 2016 at 05:30:04PM +0200, Andrey Konovalov wrote:
> The problem is that sctp_walk_errors walks the chunk before its length
> is checked for overflow.

Exactly. The check is done too late, for the 2nd and subsequent chunks
only.
Please try the following patch, thanks. Note: not even compile tested.

---8<---

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 026e3bca4a94..8ec20a64a3f8 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3422,6 +3422,12 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
+		/* Report violation if chunk len overflows */
+		ch_end = ((__u8 *)ch) + SCTP_PAD4(ntohs(ch->length));
+		if (ch_end > skb_tail_pointer(skb))
+			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
+						  commands);
+
 		/* Now that we know we at least have a chunk header,
 		 * do things that are type appropriate.
 		 */
@@ -3453,12 +3459,6 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 			}
 		}
 
-		/* Report violation if chunk len overflows */
-		ch_end = ((__u8 *)ch) + SCTP_PAD4(ntohs(ch->length));
-		if (ch_end > skb_tail_pointer(skb))
-			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
-						  commands);
-
 		ch = (sctp_chunkhdr_t *) ch_end;
 	} while (ch_end < skb_tail_pointer(skb));
 
