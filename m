From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 18212] New: force_igmp_version ignored when a IGMPv3 query
 received (+1 line patch)
Date: Fri, 10 Sep 2010 09:19:36 -0700
Message-ID: <20100910091936.75eabbf6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59751 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754699Ab0IJQUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:20:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 10 Sep 2010 15:55:04 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 18212] New: force_igmp_version ignored when a IGMPv3 query received (+1 line patch)


https://bugzilla.kernel.org/show_bug.cgi?id=18212

           Summary: force_igmp_version ignored when a IGMPv3 query
                    received (+1 line patch)
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.34.6
          Platform: All
        OS/Version: Linux
              Tree: Fedora
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: rda@rincon.com
        Regression: No


Created an attachment (id=29512)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=29512)
fix force_igmp_version v3 query problem

After all these years, it turns out that the
    /proc/sys/net/ipv4/conf/*/force_igmp_version
parameter isn't fully implemented.

*Symptom*:
When set force_igmp_version to a value of 2, the kernel should only perform
multicast IGMPv2 operations (IETF rfc2236).  An host-initiated Join message
will be sent as a IGMPv2 Join message.  But if a IGMPv3 query message is
received, the host responds with a IGMPv3 join message.  Per rfc3376 and
rfc2236, a IGMPv2 host should treat a IGMPv3 query as a IGMPv2 query and
respond with an IGMPv2 Join message.

*Consequences*:
This is an issue when a IGMPv3 capable switch is the querier and will only
issue IGMPv3 queries (which double as IGMPv2 querys) and there's an
intermediate switch that is only IGMPv2 capable.  The intermediate switch
processes the initial v2 Join, but fails to recognize the IGMPv3 Join responses
to the Query, resulting in a dropped connection when the intermediate v2-only
switch times it out.

*Identifying issue in the kernel source*:
The issue is in this section of code (in net/ipv4/igmp.c), which is called when
an IGMP query is received  (from mainline 2.6.36-rc3 gitweb):

826 static void igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
827         int len)
828 {
829         struct igmphdr          *ih = igmp_hdr(skb);
830         struct igmpv3_query *ih3 = igmpv3_query_hdr(skb);
831         struct ip_mc_list       *im;
832         __be32                  group = ih->group;
833         int                     max_delay;
834         int                     mark = 0;
835
836
837         if (len == 8) {
838                 if (ih->code == 0) {
839                         /* Alas, old v1 router presents here. */
840
841                         max_delay = IGMP_Query_Response_Interval;
842                         in_dev->mr_v1_seen = jiffies +
843                                 IGMP_V1_Router_Present_Timeout;
844                         group = 0;
845                 } else {
846                         /* v2 router present */
847                         max_delay = ih->code*(HZ/IGMP_TIMER_SCALE);
848                         in_dev->mr_v2_seen = jiffies +
849                                 IGMP_V2_Router_Present_Timeout;
850                 }
851                 /* cancel the interface change timer */
852                 in_dev->mr_ifc_count = 0;
853                 if (del_timer(&in_dev->mr_ifc_timer))
854                         __in_dev_put(in_dev);
855                 /* clear deleted report items */
856                 igmpv3_clear_delrec(in_dev);
857         } else if (len < 12) {
858                 return; /* ignore bogus packet; freed by caller */
859         } else { /* v3 */
860                 if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)))
861                         return;
862
863                 ih3 = igmpv3_query_hdr(skb);
864                 if (ih3->nsrcs) {
865                         if (!pskb_may_pull(skb, sizeof(struct igmpv3_query)
866                                            +
ntohs(ih3->nsrcs)*sizeof(__be32)))
867                                 return;
868                         ih3 = igmpv3_query_hdr(skb);
869                 }
870
871                 max_delay = IGMPV3_MRC(ih3->code)*(HZ/IGMP_TIMER_SCALE);
872                 if (!max_delay)
873                         max_delay = 1;  /* can't mod w/ 0 */
874                 in_dev->mr_maxdelay = max_delay;
875                 if (ih3->qrv)
876                         in_dev->mr_qrv = ih3->qrv;
877                 if (!group) { /* general query */
878                         if (ih3->nsrcs)
879                                 return; /* no sources allowed */
880                         igmp_gq_start_timer(in_dev);
881                         return;
882                 }
883                 /* mark sources to include, if group & source-specific */
884                 mark = ih3->nsrcs != 0;
885         }
       ... <snip> ...

A IGMPv3 query has a length >= 12 and no sources.  This routine will exit after
line 880, setting the general query timer (random timeout between 0 and query
response time).  This calls igmp_gq_timer_expire():

695 static void igmp_gq_timer_expire(unsigned long data)
696 {
697         struct in_device *in_dev = (struct in_device *)data;
698
699         in_dev->mr_gq_running = 0;
700         igmpv3_send_report(in_dev, NULL);
701         __in_dev_put(in_dev);
702 }

.. which only sends a v3 response.  So if a v3 query is received, the kernel
always sends a v3 response.  I believe the correct fix would be to change:

**PATCH**
---------------------------------
--- net/ipv4/igmp.c_orig        2010-09-10 08:48:21.390711944 -0700
+++ net/ipv4/igmp.c     2010-09-10 08:48:45.244218573 -0700
@@ -834,7 +834,7 @@
        int                     mark = 0;


-       if (len == 8) {
+       if (len == 8 || IGMP_V2_SEEN(in_dev)) {
                if (ih->code == 0) {
                        /* Alas, old v1 router presents here. */

---------------------------------

     where IGMP_V2_SEEN is previously defined as:

136 #define IGMP_V2_SEEN(in_dev) \
137         (IPV4_DEVCONF_ALL(dev_net(in_dev->dev), FORCE_IGMP_VERSION) == 2 ||
\
138          IN_DEV_CONF_GET((in_dev), FORCE_IGMP_VERSION) == 2 || \
139          ((in_dev)->mr_v2_seen && \
140           time_before(jiffies, (in_dev)->mr_v2_seen)))

We've applied, tested, and confirmed this half-line patch in our embedded
software radio product.

IGMP queries happen once every 60 sec (per vlan), so the traffic is low.  A
IGMPv3 query *is* a strict superset of a IGMPv2 query, so this patch properly
short circuit's the v3 behaviour.

One issue is that this does not address force_igmp_version=1.  Then again, I've
never seen any IGMPv1 multicast equipment in the wild.  However there is a lot
of v2-only equipment. If it's necessary to support the IGMPv1 case as well:

837         if (len == 8 || IGMP_V2_SEEN(in_dev) || IGMP_V1_SEEN(in_dev)) {

Please consider this one-line patch for inclusion in the Linux kernel.

Thank you,
-Bob Arendt / Rincon Research Corp.   rda@rincon.com

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
