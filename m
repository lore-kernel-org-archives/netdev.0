From: jamal <hadi@cyberus.ca>
Subject: Re: udp weirdness
Date: Mon, 30 Sep 2002 08:10:37 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0209300753550.11444-100000@shell.cyberus.ca>
References: <20020930084903.GA359@hookipa>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@sun.com>
In-Reply-To: <20020930084903.GA359@hookipa>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 30 Sep 2002, Eric Lemoine wrote:

> > Ok, understood. Actually we already seem to have enobufs being returned.
> >
> > Eric,
> > Does the attached patch fix it? Not tested or even compiled.
> > Someone going to change the manpages?
>
> protinfo.af_inet.recverr is a flag (1-bit variable) to enable the
> "extended reliable error message passing"; I dont see any reason
> for modifying it here. Setting this flag is the user's responsability,
> isn't it?
>

Ok, sorry, I didnt realize i was the one setting it; What i meant
was to use sk->protinfo.af_inet.recverr only in the case of all is
clean from the device layer.
i.e do something along the lines of:

--- ip_output.c	2002/09/29 08:50:36	1.1
+++ ip_output.c	2002/09/30 06:24:32
@@ -603,8 +603,11 @@
 		err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, output_maybe_reroute);
 		if (err) {
-			if (err > 0)
-				err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+			if (err > 0) {
+				err = net_xmit_errno(err);
+				if (!err && sk->protinfo.af_inet.recverr)
+				       err = sk->protinfo.af_inet.recverr;
+			}
 			if (err)
 				goto error;
 		}
@@ -713,8 +716,11 @@

 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      output_maybe_reroute);
-	if (err > 0)
-		err = sk->protinfo.af_inet.recverr ? net_xmit_errno(err) : 0;
+	if (err > 0) {
+		err = net_xmit_errno(err);
+		if (!err && sk->protinfo.af_inet.recverr)
+		       	 err = sk->protinfo.af_inet.recverr;
+	}
 	if (err)
 		goto error;
 out:
