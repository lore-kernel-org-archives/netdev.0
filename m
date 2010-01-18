From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Sun, 17 Jan 2010 21:44:24 -0800
Message-ID: <20100117214424.3cab20be@s6510>
References: <20091221095407.5430a630@nehalam>
	<20100116.014654.69913255.davem@davemloft.net>
	<201001171311.19278.christian.samsel@rwth-aachen.de>
	<20100117.185636.163664050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: christian.samsel@rwth-aachen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39675 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158Ab0ARFoq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 00:44:46 -0500
In-Reply-To: <20100117.185636.163664050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Jan 2010 18:56:36 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Christian Samsel <christian.samsel@rwth-aachen.de>
> Date: Sun, 17 Jan 2010 13:11:18 +0100
> 
> > Am Samstag, 16. Januar 2010 10:46:54 schrieb David Miller:
> >> This is a complete mess, and we need to sort it out before we think
> >> about changing the size of qopt at this point.
> >> 
> > Just to state this clearly, by cleaning up the mess you mean switching netem 
> > completely over to netlink attributes? 
> 
> I think the only way we can proceed is to keep the current qopt
> structure static, and only add things using new attributes.
> 
> I would also suggest that we make sch_netem.c strictly require a
> specific size for the structure.  And before anyone says that will
> break something, it's much better than what we have now which is
> random, silent, dropping of attributes.


Just to make it clearer. The normal netlink method of nesting attributes
(done by nla_parse_nested) is:

 +----------------------+------------
 |  len1 | type1| data1 | len2 | ...
 +----------------------+------------
 
But netem uses a sequential format:

 +------+---------------------+------------
 | qopt | len1 | type1| data1 | len2 | ...
 +------+---------------------+------------

So to enhance netlink, the best way is to add new attributes.
Changing the size of qopt will break binary compatiablity because
the code that parses sequential options will get the wrong offset.
Changing the size of attributes will also break compatiablity
as well.

Also, at some point all the functions in netem could be broken
into separate if too complex. For example, the code that was
submitted to replay a recorded trace probably would be better off
as a separate qdisc.

