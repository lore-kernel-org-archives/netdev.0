From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Kernel BUG: Qos seg. fault
Date: Mon, 24 May 2004 12:29:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524192956.89024.qmail@web80510.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-1774538402-1085426996=:88822"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, Jaume Catarineu <jaume.catarineu@upf.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0-1774538402-1085426996=:88822
Content-Type: text/plain; charset=us-ascii
Content-Id: 
Content-Disposition: inline

Hi,

Jamal wrote:
> 
> Can you try to reproduce this problem without the new changes to the
> tbf qdisc?
> Example can you reproduce this without tbf being at the root?
> I have access to a 2.4.21 and 2.6.1 machines which i cant upgrade right
> now. I also have a few spare cycles today so i could chase this.
> Get rid of tbf at root and see if this still happens
> 

Yes, it is new tbf... It does not have tcf_chain implementation so
when someone tries to add a filter to TBF it barfs. I need little
help here - does TBF need fill-blown filter support? TBF can only
have one qdisc connected to it, and if that qdisc is classful then
filters should be attached to that qdisc. Is there any need to attach
filter to TBF itself?

If TBF does not need its own filter support then the patch below
should take care of tc segfaulting (uncompiled, untested).

Dmitry

--0-1774538402-1085426996=:88822
Content-Type: text/plain; name="tbf_filter_crash.patch"
Content-Description: tbf_filter_crash.patch
Content-Disposition: inline; filename="tbf_filter_crash.patch"

diff -urN 2.6.6/net/sched/sch_tbf.c linux-2.6.6/net/sched/sch_tbf.c
--- 2.6.6/net/sched/sch_tbf.c	2004-05-11 11:24:33.777996800 -0500
+++ linux-2.6.6/net/sched/sch_tbf.c	2004-05-24 14:18:41.099267200 -0500
@@ -472,7 +472,7 @@
 {
 }
 
-static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid, 
+static int tbf_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
 			    struct rtattr **tca, unsigned long *arg)
 {
 	return -ENOSYS;
@@ -495,6 +495,11 @@
 	}
 }
 
+static struct tcf_proto **tbf_find_tcf(struct Qdisc *sch, unsigned long cl)
+{
+	return NULL;
+}
+
 static struct Qdisc_class_ops tbf_class_ops =
 {
 	.graft		=	tbf_graft,
@@ -504,6 +509,7 @@
 	.change		=	tbf_change_class,
 	.delete		=	tbf_delete,
 	.walk		=	tbf_walk,
+	.tcf_chain	=	tbf_find_tcf,
 	.dump		=	tbf_dump_class,
 };
 

--0-1774538402-1085426996=:88822--
