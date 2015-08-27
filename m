From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC] openvswitch: Retain parsed IPv6 header fields in
 flow on error skipping extension headers
Date: Thu, 27 Aug 2015 16:10:02 +0900
Message-ID: <20150827070959.GA25311@vergenet.net>
References: <1439515813-29406-1-git-send-email-simon.horman@netronome.com>
 <CALnjE+owxmLQXLZoAU4oNXToDA1hb4uvr8nj9KXCiKgcRhEOvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36228 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752398AbbH0HKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:10:13 -0400
Received: by padfo6 with SMTP id fo6so793040pad.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:10:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+owxmLQXLZoAU4oNXToDA1hb4uvr8nj9KXCiKgcRhEOvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pravin,

On Mon, Aug 17, 2015 at 11:33:59AM -0700, Pravin Shelar wrote:
> On Thu, Aug 13, 2015 at 6:30 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > When an error occurs skipping IPv6 extension headers retain the already
> > parsed IP protocol and IPv6 addresses in the flow. Also assume that the
> > packet is not a fragment in the absence of information to the contrary;
> > that is always use the frag_off value set by ipv6_skip_exthdr().
> >
> > This allows matching on the IP protocol and IPv6 addresses of packets
> > with malformed extension headers.
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >
> > ---
> >
> > * Some consideration should be given to unwanted side effects of this patch
> >   as it affects the handling of malformed packets.
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> >  net/openvswitch/flow.c | 11 +++++++----
> >  1 file changed, 7 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> > index 8db22ef73626..3c5336c5d4ea 100644
> > --- a/net/openvswitch/flow.c
> > +++ b/net/openvswitch/flow.c
> > @@ -271,8 +271,6 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
> >         key->ipv6.addr.dst = nh->daddr;
> >
> >         payload_ofs = ipv6_skip_exthdr(skb, payload_ofs, &nexthdr, &frag_off);
> > -       if (unlikely(payload_ofs < 0))
> > -               return -EINVAL;
> >
> >         if (frag_off) {
> >                 if (frag_off & htons(~0x7))
> > @@ -283,6 +281,13 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
> >                 key->ip.frag = OVS_FRAG_TYPE_NONE;
> >         }
> >
> > +       /* Delayed handling of error in ipv6_skip_exthdr() as it
> > +        * always sets frag_off to a valid value which may be
> > +        * used to set key->ip.frag above.
> > +        */
> > +       if (unlikely(payload_ofs < 0))
> > +               return -EINVAL;
> > +
> check_header() function called above also return -EINVAL, That could
> confuse caller checking for error code. So we need different error
> code here.

Thanks for pointing that out and sorry for taking so long to get back to
you. How about something like this?

-- >8 --
Subject: [PATCH v1.1] openvswitch: Retain parsed IPv6 header fields in flow on error skipping extension headers

When an error occurs skipping IPv6 extension headers retain the already
parsed IP protocol and IPv6 addresses in the flow. Also assume that the
packet is not a fragment in the absence of information to the contrary;
that is always use the frag_off value set by ipv6_skip_exthdr().

This allows matching on the IP protocol and IPv6 addresses of packets
with malformed extension headers.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---

* Some consideration should be given to unwanted side effects of this patch
  as it affects the handling of malformed packets.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 net/openvswitch/flow.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 8db22ef73626..de4366f81b11 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -271,8 +271,6 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 	key->ipv6.addr.dst = nh->daddr;
 
 	payload_ofs = ipv6_skip_exthdr(skb, payload_ofs, &nexthdr, &frag_off);
-	if (unlikely(payload_ofs < 0))
-		return -EINVAL;
 
 	if (frag_off) {
 		if (frag_off & htons(~0x7))
@@ -283,6 +281,13 @@ static int parse_ipv6hdr(struct sk_buff *skb, struct sw_flow_key *key)
 		key->ip.frag = OVS_FRAG_TYPE_NONE;
 	}
 
+	/* Delayed handling of error in ipv6_skip_exthdr() as it
+	 * always sets frag_off to a valid value which may be
+	 * used to set key->ip.frag above.
+	 */
+	if (unlikely(payload_ofs < 0))
+		return -EPROTO;
+
 	nh_len = payload_ofs - nh_ofs;
 	skb_set_transport_header(skb, nh_ofs + nh_len);
 	key->ip.proto = nexthdr;
@@ -622,12 +627,16 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 		nh_len = parse_ipv6hdr(skb, key);
 		if (unlikely(nh_len < 0)) {
-			memset(&key->ip, 0, sizeof(key->ip));
-			memset(&key->ipv6.addr, 0, sizeof(key->ipv6.addr));
-			if (nh_len == -EINVAL) {
+			switch (nh_len) {
+			case -EINVAL:
+				memset(&key->ip, 0, sizeof(key->ip));
+				memset(&key->ipv6.addr, 0, sizeof(key->ipv6.addr));
+				/* fall-through */
+			case -EPROTO:
 				skb->transport_header = skb->network_header;
 				error = 0;
-			} else {
+				break;
+			default:
 				error = nh_len;
 			}
 			return error;
-- 
2.1.4
