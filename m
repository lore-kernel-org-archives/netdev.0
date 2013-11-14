From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net v2] bonding: add ip checks when store ip target
Date: Thu, 14 Nov 2013 11:10:28 +0100
Message-ID: <20131114101028.GQ19702@redhat.com>
References: <52843700.2040509@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11735 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752761Ab3KNKMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 05:12:50 -0500
Content-Disposition: inline
In-Reply-To: <52843700.2040509@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 10:35:44AM +0800, Ding Tianhong wrote:
...snip...
>-	newtarget = in_aton(buf + 1);
>+	if (!in4_pton(buf + 1, -1, (u8 *)&newtarget, -1, NULL) ||
>+			newtarget == 0) {

Good catch on that newtarget verification, forgot to add it. However, the
previous checked not only for all-zeroes, but also for the broadcast, so
it'd be great if you could maintain the previous functionality/checks.

Or, even better, you could do something like SCTP does in
IS_IPV4_UNUSABLE_ADDRESS():

353 #define IS_IPV4_UNUSABLE_ADDRESS(a)         \
354         ((htonl(INADDR_BROADCAST) == a) ||  \
355          ipv4_is_multicast(a) ||            \
356          ipv4_is_zeronet(a) ||              \
357          ipv4_is_test_198(a) ||             \
358          ipv4_is_anycast_6to4(a))

It's up to you, though, I think that either way works good - it's
sysadmin's job to know which addresses can/have to be used.

Also, fix the identation.

Thanks!

>+		pr_err("%s: invalid ARP target %pI4 specified for addition\n",
>+		       bond->dev->name, &newtarget);
>+		goto out;
>+	}
> 	/* look for adds */
> 	if (buf[0] == '+') {
>-		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
>-			pr_err("%s: invalid ARP target %pI4 specified for addition\n",
>-			       bond->dev->name, &newtarget);
>-			goto out;
>-		}
>-
> 		if (bond_get_targets_ip(targets, newtarget) != -1) { /* dup */
> 			pr_err("%s: ARP target %pI4 is already present\n",
> 			       bond->dev->name, &newtarget);
...snip...
