From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 / match / meta bug?
Date: Tue, 29 Jul 2008 09:35:50 +0300
Message-ID: <200807290935.50100.denys@visp.net.lb>
References: <200807290843.29447.denys@visp.net.lb> <488EB632.9@trash.net> <200807290925.46731.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:45324 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbYG2GgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 02:36:13 -0400
In-Reply-To: <200807290925.46731.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, there is typo seems, i check git also, bug is there.
No idea how it works with you :-\ Maybe on your arch ULONG_MAX == LONG_MAX

So at least patch looks like: (maybe it is incorrect, i will resend if required from work as attachment)

diff -Naur iproute2/tc/em_meta.c b/tc/em_meta.c
--- iproute2/tc/em_meta.c       2008-07-29 06:31:51.000000000 +0000
+++ b/tc/em_meta.c      2008-07-29 06:31:38.000000000 +0000
@@ -262,7 +262,7 @@
        }

        num = bstrtoul(arg);
-       if (num != LONG_MAX) {
+       if (num != ULONG_MAX) {
                obj->kind = TCF_META_TYPE_INT << 12;
                obj->kind |= TCF_META_ID_VALUE;
                *dst = (unsigned long) num;
@@ -320,7 +320,7 @@
                        a = bstr_next(a);

                        shift = bstrtoul(a);
-                       if (shift == LONG_MAX) {
+                       if (shift == ULONG_MAX) {
                                PARSE_ERR(a, "meta: invalid shift, must " \
                                    "be numeric");
                                return PARSE_FAILURE;
@@ -338,7 +338,7 @@
                        a = bstr_next(a);

                        mask = bstrtoul(a);
-                       if (mask == LONG_MAX) {
+                       if (mask == ULONG_MAX) {
                                PARSE_ERR(a, "meta: invalid mask, must be " \
                                    "numeric");
                                return PARSE_FAILURE;


because 

unsigned long bstrtoul(const struct bstr *b)
{
        char *inv = NULL;
        unsigned long l;
        char buf[b->len+1];

        memcpy(buf, b->data, b->len);
        buf[b->len] = '\0';

        l = strtoul(buf, &inv, 0);
        if (l == ULONG_MAX || inv == buf)
                return ULONG_MAX;

        return l;
}





On Tuesday 29 July 2008, Denys Fedoryshchenko wrote:
> According man of stroul
> 
> RETURN VALUE
>        The strtoul() function returns either the result of the conversion or, if there was a leading minus sign, the negation of the result
>        of the conversion represented as an unsigned value, unless the original (non-negated) value would overflow; in the latter case, str-
>        toul() returns ULONG_MAX and sets the global variable errno to ERANGE.  Precisely the same holds  for  strtoull()  (with  ULLONG_MAX
>        instead of ULONG_MAX).
> 
> ULONG_MAX is NOT LONG_MAX
> 
> So it must not work i guess (2.6.26 release).
> Maybe in git it is fixed, dunno, i will check it now.
> 
> 
> On Tuesday 29 July 2008, Patrick McHardy wrote:
> > Denys Fedoryshchenko wrote:
> > > Well, the issue not with ifb0 only. It is just not parsing rules correctly i think:
> > >
> > > rich tc # ./tc filter add dev ifb0 protocol all basic match meta\(protocol eq 1234\) classid 1:100
> > > rich tc # ./tc filter add dev ifb0 protocol all basic match meta\(data_len eq 1234\) classid 1:100
> > >
> > > filter parent 1: protocol all pref 49151 basic
> > > filter parent 1: protocol all pref 49151 basic handle 0x1 flowid 1:100
> > >   meta(-1 eq 1234)
> > >
> > > filter parent 1: protocol all pref 49152 basic
> > > filter parent 1: protocol all pref 49152 basic handle 0x1 flowid 1:100
> > >   meta(-1 eq 1234)
> > >   
> > 
> > Works fine here with a fresh git checkout:
> > 
> > # tc filter add dev dummy0 protocol all parent 1: basic match 
> > meta\(protocol eq 1234\) classid 1:100
> > # tc -s -d filter show dev dummy0
> > filter parent 1: protocol all pref 49151 basic
> > filter parent 1: protocol all pref 49151 basic handle 0x1 flowid 1:100
> >   meta(protocol mask 0x00000000 eq 1234)
> > 
> > filter parent 1: protocol all pref 49152 basic
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


