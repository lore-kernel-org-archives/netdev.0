From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH 2/6] netlink: have netlink per-protocol bind function
	return an error code.
Date: Tue, 22 Apr 2014 21:30:05 -0400
Message-ID: <20140423013005.GB20182@madcap2.tricolour.ca>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
	<cover.1397831970.git.rgb@redhat.com>
	<c9a8a0879bc9f375bb3484f8e86189a8af5aa142.1397831970.git.rgb@redhat.com>
	<20140422.161904.1187535812839850973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: hadi@mojatatu.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-audit@redhat.com,
        selinux@tycho.nsa.gov
To: David Miller <davem@davemloft.net>
Return-path: <linux-audit-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20140422.161904.1187535812839850973.davem@davemloft.net>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On 14/04/22, David Miller wrote:
> From: Richard Guy Briggs <rgb@redhat.com>
> Date: Fri, 18 Apr 2014 13:34:06 -0400
> 
> > @@ -1449,6 +1453,26 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
> >  	if (!nladdr->nl_groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
> >  		return 0;
> >  
> > +	if (nlk->netlink_bind && nladdr->nl_groups) {
> > +		int i;
> > +
> > +		for (i = 0; i < nlk->ngroups; i++) {
> > +			int undo;
> > +
> > +			if (!test_bit(i, (long unsigned int *)&nladdr->nl_groups))
> > +				continue;
> > +			err = nlk->netlink_bind(i);
> > +			if (!err)
> > +				continue;
> > +			if (!nlk->portid)
> > +				netlink_remove(sk);
> > +			for (undo = 0; undo < i; undo++)
> > +				if (nlk->netlink_unbind)
> > +					nlk->netlink_unbind(undo);
> > +			return err;
> > +		}
> > +	}
> > +
> 
> It took me a while to figure out why you need to do the netlink_remove() in
> the error path.
> 
> I think it's really asking for trouble to allow the socket to have temporary
> visibility if we end up signalling an error.

The risk seems small, but I agree it is sloppy.

> It seems safest if we only do the autobind/insert once we are absolutely
> certain that the bind() will fully succeed.  This means that you have to
> do this bind validation loop before autobind/insert.

Ok, done.  This revision ends up being a bit cleaner than the previous
one because I've refactored out the unbind loop into netlink_unbind()
due to it needing to be called if the netlink_insert/autobind() fails as
well.  In the factorization process I noticed that unrequested groups
were being unnecessarily unbound.  It also provoked assigning the var
"groups" from "nladdr->nl_groups" making things easier to read.

> Please make this change and resubmit this series, thanks.

Compiled and tested.  New patchset to follow.

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
