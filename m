From: Yeoh Chun-Yeow <yeohchunyeow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] mac80211: Use correct originator sequence number in a Path
	Reply
Date: Fri, 25 May 2012 23:30:36 +0800
Message-ID: <CAEFj985HxSrOwOoevDjG1jxPxobLda-X_LZUtj6LgwXZwozBog@mail.gmail.com>
References: <1337934071-29342-1-git-send-email-qasimj@gmail.com>
Reply-To: devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ravip-DNmUmOh1Rg72fBVCVOL8/A@public.gmane.org
To: devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Return-path: <devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org>
In-Reply-To: <1337934071-29342-1-git-send-email-qasimj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.open80211s.org/cgi-bin/mailman/options/devel>,
	<mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open80211s.org/pipermail/devel>
List-Post: <mailto:devel-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <http://lists.open80211s.org/cgi-bin/mailman/listinfo/devel>,
	<mailto:devel-request-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
Errors-To: devel-bounces-ZwoEplunGu1xMJw8dq7oimD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, Qasim Javed

I think that you are referring to the target HWMP sequence number in
PREP element.

Based on the 802.11s standard, it has specified that
dot11MeshHWMPnetDiameterTraversalTime is only applied to original HWMP
sequence number for PREQ as mentioned in the "Contents of a PREQ
element" in section 11C.

For PREP element, it should be based on the description in section 11C.9.8.3:
"If it is a target mesh STA, it shall update its own HWMP sequence
number to maximum (current HWMP sequence number, target HWMP sequence
number in the PREQ) + 1 immediately before it generates a PREP in
response to a PREQ. The target HWMP sequence number of the PREQ is
relevant when a link was broken along the path and the stored sequence
number was increased at an intermediate mesh STA."

So the target HWMP sequence number should be modified as follow:

diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index 70ac7d1..5988e82 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -538,12 +538,10 @@ static void hwmp_preq_frame_process(struct
ieee80211_sub_if_data *sdata,
                forward = false;
                reply = true;
                metric = 0;
-               if (time_after(jiffies, ifmsh->last_sn_update +
-                                       net_traversal_jiffies(sdata)) ||
-                   time_before(jiffies, ifmsh->last_sn_update)) {
-                       target_sn = ++ifmsh->sn;
-                       ifmsh->last_sn_update = jiffies;
-               }
+               if (SN_LT(ifmsh->sn, target_sn))
+                       ifmsh->sn = target_sn;
+               target_sn = ++ifmsh->sn;
+               ifmsh->last_sn_update = jiffies;

Comments.

Regards,
Chun-Yeow
