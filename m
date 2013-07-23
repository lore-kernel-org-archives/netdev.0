From: JP Abgrall <jpa@google.com>
Subject: Question about default route handling/lookup in a custom table
Date: Mon, 22 Jul 2013 18:20:18 -0700
Message-ID: <CAKP4w2Q_5V=2CdyUpeXrHg=dTv1LNynp87gy6nrQYWYyBuA39A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:41597 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab3GWBUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 21:20:38 -0400
Received: by mail-oa0-f45.google.com with SMTP id j1so9966060oag.32
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 18:20:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following sequence fails when adding the default route:
(wlan0 is up, nothing is trying to manage,...)

       ip route flush dev wlan0 table all
       ip route flush table 60
       ip route add 1.1.1.1/32 dev wlan0 table 60
       ip route add default via 1.1.1.1 dev wlan0 table 60

Turns out that fib_lookup() uses the
  cfg->fc_nlinfo.nl_net->ipv4.rules_ops->rules_list
which does not contain rules for table 60.

Is there something broken with my assumptions that it should work?
Is the lack for rules for table 60 in the rules_list a red herring or
needs digging into?

With my limited understanding of why things are going wrong, I'm tempted to
 - detect that fib_look() failed and cfg->cf_table is not unspecified.
 - then do an explicit fib table lookup.

This behaviour is in 3.4.39 and I haven't seen much changes in later
versions of fib_semantics.c or related files that might apply.

* diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index c60a396..acf019d 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -567,6 +567,14 @@ static int fib_check_nh(struct fib_config *cfg,
struct fib_info *fi,
                        if (fl4.flowi4_scope < RT_SCOPE_LINK)
                                fl4.flowi4_scope = RT_SCOPE_LINK;
                        err = fib_lookup(net, &fl4, &res);
+                       if (err && cfg->fc_table != RT_TABLE_UNSPEC) {
+                               struct fib_table *table;
+                               table = fib_get_table(net, cfg->fc_table);
+                               if (table &&
+                                   !fib_table_lookup(table, &fl4, &res,
+                                                     FIB_LOOKUP_NOREF))
+                                       err = 0;
+                       }
                        if (err) {
                                rcu_read_unlock();
                                return err;


* This is the sequence of function calls I thought were relevant for
the "ip route add default ...table 60":

inet_rtm_newroute(): table=60 scope=0
fib_table_insert(): table=60 dst=0x0 type=1
fib_create_info(): fc_mx=0x  (null) table=60 fi=0xc5266a00
fib_create_info(): fc_mp=0x  (null) table=60 fi=0xc5266a00
fib_create_info(): props[fc_type=1].error=0 table=60 fi=0xc5266a00
fib_create_info(): cfg.table=60 scope=0
fib_check_nh(): table=60 nh_gw=0x1010101 nh_flags=0x0
fib_lookup(): table ?:
fib_rules_lookup(): rule.table=255:
fib4_rule_action(): table 255: action=1
fib_table_lookup(): tb.id=255 tb.numdflt=0
fib_table_lookup(): tb.id=255 pn{}: pref_mismatch
fib_table_lookup(): tb.id=255 pn{}: chopped_off(3) > pn->bits(2)
fib_rules_lookup(): rule.table=254:
fib4_rule_action(): table 254: action=1
fib_table_lookup(): tb.id=254 tb.numdflt=1
fib_table_lookup(): tb.id=254 pn{}: chopped_off(3) > pn->bits(2)
fib_rules_lookup(): rule.table=253:
fib4_rule_action(): table 253: action=1
fib_check_nh(): table=60 fib_lookup(fc_scope=253)=-3 res.type=0  <<<
this is where it would normally fail.
fib_check_nh(): table=60 fib_get_table(table=60)=c53d7cc0  <<< This is
where the added code kicks in.
fib_table_lookup(): tb.id=60 tb.numdflt=0
fib_table_lookup(): tb.id=60 check_leaf()=0 res.type=1
fib_check_nh(): table=60 fib_table_lookup()=0 res.type=1
fib_create_info(): cfg.table=60 check_nh()=0
fib_create_info(): table=60 fi=0xc5266a00
fib_table_insert(): table=60 fib_create_info()=xc5266a00
fib_table_insert(): table=60 created new_fa=xc4459f00->type=1
inet_rtm_newroute(): table=60 err=0  <<< It now succeeds.

--
