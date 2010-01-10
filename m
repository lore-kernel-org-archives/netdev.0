From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 1/1] NET: ipv6, fix potential null dereference
Date: Sun, 10 Jan 2010 12:05:07 +0100
Message-ID: <4B49B463.3010502@gmail.com>
References: <20100110103528.GA4769@x200> <4B49AE41.5000206@gmail.com> <20100110104742.GC4769@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:43077 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342Ab0AJLFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 06:05:10 -0500
Received: by fg-out-1718.google.com with SMTP id 22so352185fge.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2010 03:05:09 -0800 (PST)
In-Reply-To: <20100110104742.GC4769@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2010 11:47 AM, Alexey Dobriyan wrote:
> On Sun, Jan 10, 2010 at 11:38:57AM +0100, Jiri Slaby wrote:
>> On 01/10/2010 11:35 AM, Alexey Dobriyan wrote:
>>>> Stanse found a potential null dereference
>>>
>>> Nobody learns from Coverity, it seems. :^)
>>
>> If it is known, why the test is still there?
>>
>> I don't have access to the Coverity results anyway.
> 
> Well, when Coverity first exposed their database there were innumerable
> "potential NULL dereference" defects and people fixed them by moving
> stuff and most were bogus and there were flamewars and there were second
> wave and so on...

Well, it is a clear error. Either the check is superfluous, or there is
a potential NULL dereference.

And until people start to look at the reports for their stuff
themselves, they will get bogus fixes from others. And they have to nack
them, indeed.

While we are at it, could anybody look at (watch `task'):
int xprt_reserve_xprt(struct rpc_task *task)
{
        struct rpc_rqst *req = task->tk_rqstp; <---- here
        struct rpc_xprt *xprt = req->rq_xprt;

        if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
                if (task == xprt->snd_task)
                        return 1;
                if (task == NULL)  <------- here
                        return 0;

And this (I checked 2.6.28, where netdev_priv was dev->priv):
static void __devexit de_remove_one (struct pci_dev *pdev)
{
        struct net_device *dev = pci_get_drvdata(pdev);
        struct de_private *de = netdev_priv(dev);

        BUG_ON(!dev);

I know, currently netdev_priv returns dev+offset, but will this hold in
the future?

>>> snmp6_unregister_dev() always called with valid idev.
> 
> irda patch is not right too: calling tty->ops->hook with NULL tty is
> impossible.

Yup, I somehow messed with tty->driver_data being NULL.

thanks,
-- 
js
