From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: MLD problems (again)
Date: Tue, 6 Jan 2004 13:44:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB92352E7.7549AEDC-ON88256E13.0074177C@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE480DFE791EC8f9e8a93df938690918c07BBE480DFE791EC"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Takashi Hibi <hibi665@oki.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE480DFE791EC8f9e8a93df938690918c07BBE480DFE791EC
Content-type: text/plain; charset=US-ASCII





Takashi,
      I am looking at this-- I just haven't been in the office for the last
two weeks. I haven't looked at it in detail, but I believe there are
problems
with your patch.

Offhand:
1) you added a check "if (skb) skb = addgrec(skb...)"
      "skb == NULL" is a perfectly valid argument for addgrec(), and
there aren't any circumstances I know of where you'd want to only add
the record when no others had been added yet (which appears to be
what this code is doing). So, this looks completely wrong to me. Either
you want the record or not and it doesn't depend on whether you have
other records in the report or not.

2) your patch adds a set of crcount within ip_mc_add1_src(), which if
necessary would mean the other code is completely broken (which it
isn't). I think this is likely either redundant or it may break other
assumptions
about crcount handling. There are potential races I avoided in this code,
so I'm wary of why you put that in there, but I'm pretty sure it's at best
unnecessary.

3) it is not correct to always automatically join a group if it's listed in
a
setsockopt(). I think the result of your patch to fix your problem would
also automatically join groups in cases where it should return an error.

General comment-- the code is set up with the assumption that an
ordinary join has a filter of "EXCLUDE, empty-set". That's because
the protocol makes that assumption, and reports for includes of new
groups are CHANGE_TO_INCLUDE. It looks like you're trying to
bypass that and set the filter directly to INCLUDE, which I expect would
result in incorrect reports for some cases.

Again, I have only looked at the patch context in your mail, so some of
the things I think are problems probably aren't. I suspect, though, that
the
original cause of your problem is simply a missing "mld_ifc_event" call,
though I'm not sure. Those are also carefully constructed to try to avoid
multiple reports for complex transitions, when only one report will do, so
some care is needed. I will look at this further and try to have an
alternative
patch by the end of the week.

                              +-DLS


Takashi Hibi <hibi665@oki.com>@oss.sgi.com on 01/06/2004 04:15:42 AM

Sent by:    netdev-bounce@oss.sgi.com


To:    netdev@oss.sgi.com
cc:
Subject:    MLD problems (again)



A Happy new year.

Let me discuss about the problems of MLD again.
As I pointed out, there are two problems in current MLD code.

1. In MLDv1 compatibility mode, Older Version Querier Present timer expires
   prematurely.
2. After join SSM using setsockopt(MCAST_JOIN_SOURCE_GROUP),
   MLDv2 listener report isn't issued immediately.

The cause of 1 is the wrong computation of timeout value.
The cause of 2 is difficult to find. After tracing the code,
I figured out that the mode of ifmcaddr6 isn't correctly set after
setsockopt.

After join by setsockopt, pmc->mca_sfmode should be MCAST_INCLUDE,
but it remains MCAST_EXCLUDE. Eventually is_in() call returns false,
and MLDv2 packet isn't composed.
I don't know the right way to fix it, since the code is too complicated
by a lot of flags.
At least the following patch(diff from 2.6.0) works for me.

Regards,
Takashi Hibi

--- mcast.c 2003-12-18 11:59:28.000000000 +0900
+++ new/mcast.c   2004-01-06 16:30:05.546174486 +0900
@@ -1050,7 +1050,7 @@ int igmp6_event_query(struct sk_buff *sk
   /* Translate milliseconds to jiffies */
   max_delay = (ntohs(hdr->icmp6_maxdelay)*HZ)/1000;

-           switchback = (idev->mc_qrv + 1) * max_delay;
+           switchback = MLD_QRV_DEFAULT * 125*HZ + max_delay;
   idev->mc_v1_seen = jiffies + switchback;

   /* cancel the interface change timer */
@@ -1541,7 +1541,8 @@ static void mld_send_cr(struct inet6_dev
     type = MLD2_CHANGE_TO_EXCLUDE;
    else
     type = MLD2_CHANGE_TO_INCLUDE;
-                 skb = add_grec(skb, pmc, type, 0, 0);
+                 if (!skb)
+                       skb = add_grec(skb, pmc, type, 0, 0);
   }
   spin_unlock_bh(&pmc->mca_lock);
  }
@@ -1745,6 +1746,7 @@ static int ip6_mc_add1_src(struct ifmcad
    return -ENOBUFS;
   memset(psf, 0, sizeof(*psf));
   psf->sf_addr = *psfsrc;
+     psf->sf_crcount = pmc->idev->mc_qrv;
   if (psf_prev) {
    psf_prev->sf_next = psf;
   } else
@@ -1799,6 +1801,7 @@ int ip6_mc_add_src(struct inet6_dev *ide
  struct ifmcaddr6 *pmc;
  int isexclude;
  int i, err;
+     int     first_join_src_grp;

  if (!idev)
   return -ENODEV;
@@ -1816,6 +1819,8 @@ int ip6_mc_add_src(struct inet6_dev *ide

  sf_markstate(pmc);
  isexclude = pmc->mca_sfmode == MCAST_EXCLUDE;
+     first_join_src_grp = (!pmc->sources && sfmode == MCAST_INCLUDE &&
+           sfcount == 1 && delta);
  if (!delta)
   pmc->mca_sfcount[sfmode]++;
  err = 0;
@@ -1827,10 +1832,19 @@ int ip6_mc_add_src(struct inet6_dev *ide
  if (err) {
   int j;

-           pmc->mca_sfcount[sfmode]--;
+           if (!delta)
+                 pmc->mca_sfcount[sfmode]--;
   for (j=0; j<i; j++)
    (void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
-     } else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
+           goto done;
+     }
+     if (first_join_src_grp) {
+           pmc->mca_sfmode = MCAST_INCLUDE;
+           if (sf_setstate(pmc))
+                 mld_ifc_event(idev);
+           goto done;
+     }
+     if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
   struct inet6_dev *idev = pmc->idev;
   struct ip6_sf_list *psf;

@@ -1848,6 +1862,7 @@ int ip6_mc_add_src(struct inet6_dev *ide
   mld_ifc_event(idev);
  } else if (sf_setstate(pmc))
   mld_ifc_event(idev);
+done:
  spin_unlock_bh(&pmc->mca_lock);
  read_unlock_bh(&idev->lock);
  return err;



--0__=07BBE480DFE791EC8f9e8a93df938690918c07BBE480DFE791EC
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Takashi,<br>
	I am looking at this-- I just haven't been in the office for the last<br>
two weeks. I haven't looked at it in detail, but I believe there are problems<br>
with your patch.<br>
<br>
Offhand:<br>
1) you added a check &quot;if (skb) skb = addgrec(skb...)&quot; <br>
	&quot;skb == NULL&quot; is a perfectly valid argument for addgrec(), and<br>
there aren't any circumstances I know of where you'd want to only add<br>
the record when no others had been added yet (which appears to be<br>
what this code is doing). So, this looks completely wrong to me. Either<br>
you want the record or not and it doesn't depend on whether you have<br>
other records in the report or not.<br>
<br>
2) your patch adds a set of crcount within ip_mc_add1_src(), which if<br>
necessary would mean the other code is completely broken (which it<br>
isn't). I think this is likely either redundant or it may break other assumptions<br>
about crcount handling. There are potential races I avoided in this code,<br>
so I'm wary of why you put that in there, but I'm pretty sure it's at best<br>
unnecessary.<br>
<br>
3) it is not correct to always automatically join a group if it's listed in a<br>
setsockopt(). I think the result of your patch to fix your problem would<br>
also automatically join groups in cases where it should return an error.<br>
<br>
General comment-- the code is set up with the assumption that an<br>
ordinary join has a filter of &quot;EXCLUDE, empty-set&quot;. That's because<br>
the protocol makes that assumption, and reports for includes of new<br>
groups are CHANGE_TO_INCLUDE. It looks like you're trying to<br>
bypass that and set the filter directly to INCLUDE, which I expect would<br>
result in incorrect reports for some cases.<br>
<br>
Again, I have only looked at the patch context in your mail, so some of<br>
the things I think are problems probably aren't. I suspect, though, that the<br>
original cause of your problem is simply a missing &quot;mld_ifc_event&quot; call,<br>
though I'm not sure. Those are also carefully constructed to try to avoid<br>
multiple reports for complex transitions, when only one report will do, so<br>
some care is needed. I will look at this further and try to have an alternative<br>
patch by the end of the week.<br>
<br>
					+-DLS<br>
<br>

<p><font size="2" color="#800080">Sent by:	netdev-bounce@oss.sgi.com</font>
<p><font size="2" color="#800080">To:	</font><font size="2">netdev@oss.sgi.com</font><br>
<font size="2" color="#800080">cc:	 </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">MLD problems (again)</font><br>
<br>
<br>
<br>
<tt>A Happy new year.<br>
</tt><br>
<tt>Let me discuss about the problems of MLD again.<br>
As I pointed out, there are two problems in current MLD code.<br>
</tt><br>
<tt>1. In MLDv1 compatibility mode, Older Version Querier Present timer expires<br>
prematurely.</tt><br>
<tt>2. After join SSM using setsockopt(MCAST_JOIN_SOURCE_GROUP),<br>
MLDv2 listener report isn't issued immediately.</tt><br>
<br>
<tt>The cause of 1 is the wrong computation of timeout value.<br>
The cause of 2 is difficult to find. After tracing the code,<br>
I figured out that the mode of ifmcaddr6 isn't correctly set after<br>
setsockopt.<br>
</tt><br>
<tt>After join by setsockopt, pmc-&gt;mca_sfmode should be MCAST_INCLUDE,<br>
but it remains MCAST_EXCLUDE. Eventually is_in() call returns false,<br>
and MLDv2 packet isn't composed.<br>
I don't know the right way to fix it, since the code is too complicated<br>
by a lot of flags.<br>
At least the following patch(diff from 2.6.0) works for me.<br>
</tt><br>
<tt>Regards,<br>
Takashi Hibi<br>
</tt><br>
<tt>--- mcast.c	2003-12-18 11:59:28.000000000 +0900<br>
+++ new/mcast.c	2004-01-06 16:30:05.546174486 +0900<br>
@@ -1050,7 +1050,7 @@ int igmp6_event_query(struct sk_buff *sk</tt>
<ul><tt>/* Translate milliseconds to jiffies */<br>
max_delay = (ntohs(hdr-&gt;icmp6_maxdelay)*HZ)/1000;</tt><br>
</ul>
<tt>-		switchback = (idev-&gt;mc_qrv + 1) * max_delay;<br>
+		switchback = MLD_QRV_DEFAULT * 125*HZ + max_delay;</tt>
<ul><tt>idev-&gt;mc_v1_seen = jiffies + switchback;<br>
</tt></ul>
<tt>/* cancel the interface change timer */<br>
@@ -1541,7 +1541,8 @@ static void mld_send_cr(struct inet6_dev</tt>
<ul><tt>type = MLD2_CHANGE_TO_EXCLUDE;<br>
else</tt></ul>
<tt>type = MLD2_CHANGE_TO_INCLUDE;<br>
-			skb = add_grec(skb, pmc, type, 0, 0);<br>
+			if (!skb)<br>
+				skb = add_grec(skb, pmc, type, 0, 0);</tt>
<ul><tt>}<br>
spin_unlock_bh(&amp;pmc-&gt;mca_lock);</tt></ul>
<tt>}<br>
@@ -1745,6 +1746,7 @@ static int ip6_mc_add1_src(struct ifmcad</tt>
<ul><tt>return -ENOBUFS;<br>
memset(psf, 0, sizeof(*psf));<br>
psf-&gt;sf_addr = *psfsrc;</tt></ul>
<tt>+		psf-&gt;sf_crcount = pmc-&gt;idev-&gt;mc_qrv;<br>
if (psf_prev) {</tt>
<ul><tt>psf_prev-&gt;sf_next = psf;<br>
} else</tt></ul>
<tt>@@ -1799,6 +1801,7 @@ int ip6_mc_add_src(struct inet6_dev *ide<br>
struct ifmcaddr6 *pmc;<br>
int	isexclude;<br>
int	i, err;</tt><br>
<tt>+	int &nbsp; &nbsp; first_join_src_grp;<br>
</tt>
<ul><tt>if (!idev)<br>
return -ENODEV;</tt></ul>
<tt>@@ -1816,6 +1819,8 @@ int ip6_mc_add_src(struct inet6_dev *ide<br>
</tt>
<ul><tt>sf_markstate(pmc);<br>
isexclude = pmc-&gt;mca_sfmode == MCAST_EXCLUDE;</tt></ul>
<tt>+	first_join_src_grp = (!pmc-&gt;sources &amp;&amp; sfmode == MCAST_INCLUDE &amp;&amp;<br>
+		sfcount == 1 &amp;&amp; delta);</tt>
<ul><tt>if (!delta)<br>
pmc-&gt;mca_sfcount[sfmode]++;</tt></ul>
<tt>err = 0;<br>
@@ -1827,10 +1832,19 @@ int ip6_mc_add_src(struct inet6_dev *ide</tt>
<ul><tt>if (err) {<br>
int j;</tt><br>
</ul>
<tt>-		pmc-&gt;mca_sfcount[sfmode]--;<br>
+		if (!delta)<br>
+			pmc-&gt;mca_sfcount[sfmode]--;</tt>
<ul><tt>for (j=0; j&lt;i; j++)<br>
(void) ip6_mc_del1_src(pmc, sfmode, &amp;psfsrc[i]);</tt></ul>
<tt>-	} else if (isexclude != (pmc-&gt;mca_sfcount[MCAST_EXCLUDE] != 0)) {<br>
+		goto done;<br>
+	}<br>
+	if (first_join_src_grp) {<br>
+		pmc-&gt;mca_sfmode = MCAST_INCLUDE;<br>
+		if (sf_setstate(pmc))<br>
+			mld_ifc_event(idev);<br>
+		goto done;<br>
+	}<br>
+	if (isexclude != (pmc-&gt;mca_sfcount[MCAST_EXCLUDE] != 0)) {</tt>
<ul><tt>struct inet6_dev *idev = pmc-&gt;idev;<br>
struct ip6_sf_list *psf;</tt><br>
</ul>
<tt>@@ -1848,6 +1862,7 @@ int ip6_mc_add_src(struct inet6_dev *ide<br>
mld_ifc_event(idev);</tt>
<ul><tt>} else if (sf_setstate(pmc))<br>
mld_ifc_event(idev);</tt></ul>
<tt>+done:<br>
spin_unlock_bh(&amp;pmc-&gt;mca_lock);<br>
read_unlock_bh(&amp;idev-&gt;lock);<br>
return err;</tt><br>
<br>
<br>
<br>
</body></html>
--0__=07BBE480DFE791EC8f9e8a93df938690918c07BBE480DFE791EC--
