From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: fix div by zero while enslaving and
 transmitting
Date: Fri, 12 Sep 2014 07:45:52 -0700
Message-ID: <1410533152.7106.95.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410524556-27128-1-git-send-email-nikolay@redhat.com>
	 <1410527381.7106.81.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5412F4D5.3070101@redhat.com> <5412F643.10007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:48469 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbaILOpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 10:45:53 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so1374567pdj.36
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 07:45:53 -0700 (PDT)
In-Reply-To: <5412F643.10007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 15:33 +0200, Nikolay Aleksandrov wrote:

> One more thing, netdev_master_upper_dev_link_private() which is called
> after the increment uses list_add_rcu() (i.e. rcu_assign_pointer) to insert
> the slave, so there's a barrier there to ensure this is visible before the
> slave is linked.

You missed my point.

You fixed the writer side, without adding barriers on the read side.

Without looking at the code, just reading your patch, I spot a problem.

Following code is fundamentally broken :

rcu_read_lock();

if (bond->list) {
    x = y % bond->slave;  // bug : cpu could fetch bond->slave before  bond->list

rcu_read_unlock();


Because it needs a read barrier, since the writer does after your patch:

	update bond->slave
	smp_wmb();
	update bond->list

I repeat : adding few rcu_read_lock() / rcu_read_unlock() /
rcu_assign_pointer() calls is not enough to guarantee code is not
broken.
