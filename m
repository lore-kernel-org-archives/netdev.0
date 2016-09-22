From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Thu, 22 Sep 2016 11:21:38 +0200
Message-ID: <20160922092138.GA12108@salvia>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
 <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org>
 <20160921154533.GA13656@salvia>
 <20160921184827.GA15732@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>, htejun-b10kYP2dOMg@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160921184827.GA15732-4EA/1caXOu0mYvmMESoHnA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 21, 2016 at 08:48:27PM +0200, Thomas Graf wrote:
> On 09/21/16 at 05:45pm, Pablo Neira Ayuso wrote:
> > On Tue, Sep 20, 2016 at 06:43:35PM +0200, Daniel Mack wrote:
> > > The point is that from an application's perspective, restricting the
> > > ability to bind a port and dropping packets that are being sent is a
> > > very different thing. Applications will start to behave differently if
> > > they can't bind to a port, and that's something we do not want to happen.
> > 
> > What is exactly the problem? Applications are not checking for return
> > value from bind? They should be fixed. If you want to collect
> > statistics, I see no reason why you couldn't collect them for every
> > EACCESS on each bind() call.
> 
> It's not about applications not checking the return value of bind().
> Unfortunately, many applications (or the respective libraries they use)
> retry on connect() failure but handle bind() errors as a hard failure
> and exit. Yes, it's an application or library bug but these
> applications have very specific exceptions how something fails.
> Sometimes even going from drop to RST will break applications.
> 
> Paranoia speaking: by returning errors where no error was returned
> before, undefined behaviour occurs. In Murphy speak: things break.
> 
> This is given and we can't fix it from the kernel side. Returning at
> system call level has many benefits but it's not always an option.
> 
> Adding the late hook does not prevent filtering at socket layer to
> also be added. I think we need both.

I have a hard time to buy this new specific hook, I think we should
shift focus of this debate, this is my proposal to untangle this:

You add a net/netfilter/nft_bpf.c expression that allows you to run
bpf programs from nf_tables. This expression can either run bpf
programs in a similar fashion to tc+bpf or run the bpf program that
you have attached to the cgroup.

To achieve this, I'd suggest you also add a new bpf chain type. That
new chain type would basically provide raw access to netfilter hooks
via nf_tables netlink interface.  This bpf chain would exclusively
take rules that use this new bpf expression.

I see good things on this proposal:

* This is consistent to what we offer via tc+bpf.

* It becomes easily visible to the user that a bpf program is running
  from the packet path, or any cgroup+bpf filtering is going on. Thus,
  no matter what those orchestrators do, this filtering becomes
  visible to sysadmins that are familiar with the existing command line
  tooling.

* You get access to all of the existing netfilter hooks in one go.

A side note on this: I would suggest this conversation focuses on
discussing aspects at a slightly higher level rather than counting raw
load and stores instructions...  I think this effort requires looking
at the whole forest, instead barfing at one single tree. Genericity
always comes at a slight cost, and to all those programmability fans
here, please remember we have a generic stack between hands after all.
So let's try to accomodate this new requirements in a way that makes
sense.

Thanks.
