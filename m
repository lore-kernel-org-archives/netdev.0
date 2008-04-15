From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_api: fix qdisc_tree_decrease_qlen() loop
Date: Tue, 15 Apr 2008 15:09:53 +0200
Message-ID: <4804A921.6050509@trash.net>
References: <20080413121031.GA5211@ami.dom.local> <20080414202605.GA6164@ami.dom.local> <4803BE84.4040105@trash.net> <20080414.151102.169978802.davem@davemloft.net> <20080415053253.GA3920@ff.dom.local> <4804A18C.2060200@trash.net> <20080415130045.GB4993@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050601000909030502070003"
Cc: David Miller <davem@davemloft.net>, enrico@superclick.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36690 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbYDONJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 09:09:55 -0400
In-Reply-To: <20080415130045.GB4993@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050601000909030502070003
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
> On Tue, Apr 15, 2008 at 02:37:32PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> On Mon, Apr 14, 2008 at 03:11:02PM -0700, David Miller wrote:
>>> ...
>>>>> Jarek Poplawski wrote:
>>> ...
>>>>>> After this fix qdisc_lookup() is omitted both for ingress and root
>>>>>> parents, but looking for root is only wasting a little time here...
>>> ...Actually, there is yet a possibility that somebody uses ffff:
>>> handle for a qdisc (not ingress), which could make here a little
>>> difference, so this place could be improved for this case (even
>>> with something like my earlier debugging patch in this thread,
>>> which BTW could be a safety for maybe some other quirks here),
>>> but it seems it would be better to discourage using this handle
>>> for anything but ingress.
>>
>> I don't think we should do that, it would be preferable to
>> compare the entire handle instead of just the major to avoid
>> this.
> 
> Probably you are right... I guess you could handle this?


On second thought I agree with you, the behaviour is inconsistent
and FFFF: shouldn't be used as major, otherwise the major doesn't
uniquely identify a qdisc anymore.


--------------050601000909030502070003
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fc8708a..c486e9d 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -386,7 +386,7 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, unsigned int n)
 	if (n == 0)
 		return;
 	while ((parentid = sch->parent)) {
-		if (TC_H_MAJ(parentid) == TC_H_MAJ(TC_H_INGRESS))
+		if (parentid == TC_H_INGRESS)
 			return;
 
 		sch = qdisc_lookup(sch->dev, TC_H_MAJ(parentid));

--------------050601000909030502070003--
