From: Moni Shoua <monis@voltaire.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Sun, 14 Oct 2007 17:51:15 +0200
Message-ID: <47123AF3.9010201@voltaire.com>
References: <11916151232222-git-send-email-fubar@us.ibm.com>	<470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org>	<20071009.181246.41634534.davem@davemloft.net> <706.1191979132@death>	<470CF7E1.6060503@voltaire.com> <aday7eaddod.fsf@cisco.com>	<470E37AD.3070408@voltaire.com> <ada3awhcsnw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, David Miller <davem@davemloft.net>,
	ogerlitz@voltaire.com, netdev@vger.kernel.org,
	Moni Levy <monil@voltaire.com>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:57427 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751463AbXJNPvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Oct 2007 11:51:35 -0400
In-Reply-To: <ada3awhcsnw.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > It happens only when ib interfaces are slaves of a bonding device.
>  > I thought before that the stuck is in napi_disable() but it's almost right.
>  > I put prints before and after call to napi_disable and see that it is called twice.
>  > I'll try to investigate in this direction.
>  > 
>  > ib0: stopping interface
>  > ib0: before napi_disable
>  > ib0: after napi_disable
>  > ib0: downing ib_dev
>  > ib0: All sends and receives done.
>  > ib0: stopping interface
>  > ib0: before napi_disable
> 
> Yes, two napi_disable()s in a row without a matching napi_enable()
> will deadlock.  I guess the question is why the ipoib interface is
> being stopped twice.
> 
> If you just take the net-2.6.24 tree (without bonding patches), does
> bonding for ethernet interfaces work OK, or is there a similar problem
> with double napi_disable()?  How about bonding of ethernet after this
> batch of bonding patches?
> 
>  - R.

Ok, I think I know what happens here.
When bonding gets an NETDEV_GOING_DONW event it releases the slave and 
by the way closes the slave device (this is a new code). ifconfig on the other hand
closes the deivice one more time and this is why we see 2 napi_disable() in a row.

The fix in my opinion is in bonding - it should react to NETDEV_UNREGISTER and not to NETDEV_GOING_DONW.
I want to test this point and if it's good I'll submit new patches.


thanks
  MoniS

