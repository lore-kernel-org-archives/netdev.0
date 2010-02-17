From: jamal <hadi@cyberus.ca>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Wed, 17 Feb 2010 18:32:09 -0500
Message-ID: <1266449529.17794.157.camel@bigi>
References: <20100217191718.GA5256@x200>  <1266442972.17794.51.camel@bigi>
	 <1266448038.17794.135.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-GgLDJnSf8b8TBsYJZOkF"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f178.google.com ([209.85.221.178]:57664 "EHLO
	mail-qy0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755563Ab0BQXcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 18:32:13 -0500
Received: by qyk8 with SMTP id 8so2371616qyk.24
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2010 15:32:11 -0800 (PST)
In-Reply-To: <1266448038.17794.135.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GgLDJnSf8b8TBsYJZOkF
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2010-02-17 at 18:07 -0500, jamal wrote:
> When you flush
> an empty table, the time goes up from about 1.5s
> to 3 secs with pfkey. You also see the EAGAIN for
> each flush ...
> I am going to dig a little more ..

Here is a fix. The speed is restored (actually looks a little better
now) - the only thing is if you try to flush an empty table we return
-ESRCH; this seems reasonable, no? So a script like following 

---
#!/usr/sbin/setkey -f
flush;
spdflush;
----

will get:
---
bigismall:~# time setkey -f ./setkey-sample
The result of line 2: No such process.
The result of line 3: No such process.

real	0m0.663s
user	0m0.080s
sys	0m0.128s
----

cheers,
jamal

--=-GgLDJnSf8b8TBsYJZOkF
Content-Disposition: attachment; filename="incr-flush-pfkey"
Content-Type: text/x-patch; name="incr-flush-pfkey"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 8b8e26a..79d2c0f 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1751,7 +1751,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	audit_info.secid = 0;
 	err = xfrm_state_flush(net, proto, &audit_info);
 	if (err)
-		return 0;
+		return err;
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
@@ -2713,7 +2713,7 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	audit_info.secid = 0;
 	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
 	if (err)
-		return 0;
+		return err;
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;

--=-GgLDJnSf8b8TBsYJZOkF--

