From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 22:18:18 +0100
Message-ID: <1269379098.2915.34.camel@edumazet-laptop>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
	 <1269377667.2915.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:59188 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab0CWVSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 17:18:23 -0400
Received: by bwz1 with SMTP id 1so2286221bwz.21
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 14:18:21 -0700 (PDT)
In-Reply-To: <1269377667.2915.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 23 mars 2010 =C3=A0 21:54 +0100, Eric Dumazet a =C3=A9crit :
> I wonder if ticket spinlocks are not the problem. Maybe we want a
> variant of spinlocks, so that cpu doing transmits can get the lock
> before other cpus...

Something like this portable implementation :

struct spinprio {
	spinlock_t	lock;
	int		highprio_cnt;
};

void spinprio_lock(struct spinprio *l)
{
	while (1) {
		spin_lock(&l->lock);
		if (!l->highprio_cnt)
			break;
		spin_unlock(&l->lock);
		cpu_relax();
	}
}

void spinprio_unlock(struct spinprio *l)
{
	spin_unlock(&l->lock);
}

void spinprio_relock(struct spinprio *l)
{
	l->highprio_cnt =3D 1;
	spin_lock(&l->lock);
	l->highprio_cnt =3D 0;
}

We would have to use spinprio_unlock()/spinprio_relock() in
sch_direct_xmit()



