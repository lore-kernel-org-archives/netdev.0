From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 30 Aug 2004 18:14:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093904088.1043.12.camel@jzny.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
	 <20040830144033.2265a6e6.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-QjZBZsTjJ1dNBVK0TS0q"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040830144033.2265a6e6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-QjZBZsTjJ1dNBVK0TS0q
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2004-08-30 at 17:40, David S. Miller wrote:
> On 29 Aug 2004 13:13:52 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > Opinions welcome - If all is good, Dave please apply.
> 
> tc_stats changes size, how will existing applications cope?
> Since it is just RTA_PUT() into userspace, will that just work
> or will existing apps bomb because they'll do a check of the
> size field of the rtnetlink attribute?

To look at an existing app such as tc; attached is a patch.
In the tc case. The possibilities are:

1) old kernels + old tc --> should work 
2) new kernels + old tc --> should work
3) new kernels + new tc --> should work
4) old kernel +  new tc --> will bomb (sizeof check will fail)

Cant think of something smart to do with option #4. I have contemplated
playing with offsetoff() etc. The best thing i can think of right
now is to complain about it as in that fprintf()

Thoughts?

cheers,
jamal


--=-QjZBZsTjJ1dNBVK0TS0q
Content-Disposition: attachment; filename=reqs-patch-iproute2-2.6.8
Content-Type: text/plain; name=reqs-patch-iproute2-2.6.8; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- iproute2-2.6.8/include/linux/pkt_sched.h	2004-08-23 16:22:16.000000000 -0400
+++ iproute2-2.6.8-mod/include/linux/pkt_sched.h	2004-08-27 10:18:32.000000000 -0400
@@ -38,6 +38,7 @@
 	__u32	pps;			/* Current flow packet rate */
 	__u32	qlen;
 	__u32	backlog;
+	__u32	reqs;
 };
 
 struct tc_estimator
--- iproute2-2.6.8/tc/tc_qdisc.c	2004-08-23 16:22:16.000000000 -0400
+++ iproute2-2.6.8-mod/tc/tc_qdisc.c	2004-08-29 13:20:25.000000000 -0400
@@ -171,8 +171,8 @@
 {
 	SPRINT_BUF(b1);
 
-	fprintf(fp, " Sent %llu bytes %u pkts (dropped %u, overlimits %u ) ",
-		(unsigned long long)st->bytes, st->packets, st->drops, st->overlimits);
+	fprintf(fp, " Sent %llu bytes %u pkts (dropped %u, overlimits %u requeus%u ) ",
+		(unsigned long long)st->bytes, st->packets, st->drops, st->overlimits, st->reqs);
 	if (st->bps || st->pps || st->qlen || st->backlog) {
 		fprintf(fp, "\n ");
 		if (st->bps || st->pps) {
@@ -255,8 +255,13 @@
 	fprintf(fp, "\n");
 	if (show_stats) {
 		if (tb[TCA_STATS]) {
+			/* FIXME: need to work with old kernels.
+			 * At the moment this just catches them
+			*/
 			if (RTA_PAYLOAD(tb[TCA_STATS]) < sizeof(struct tc_stats))
-				fprintf(fp, "statistics truncated");
+				fprintf(fp, "statistics truncated ");
+				fprintf (fp, "expected %d bytes got %d\n",sizeof(struct tc_stats),RTA_PAYLOAD(tb[TCA_STATS]));
+				fprintf("Maybe an old kernel?");
 			else {
 				struct tc_stats st;
 				memcpy(&st, RTA_DATA(tb[TCA_STATS]), sizeof(st));

--=-QjZBZsTjJ1dNBVK0TS0q--
