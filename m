From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: return errno -ENOMEM when exceeding
 RLIMIT_MEMLOCK
Date: Tue, 21 Feb 2017 23:14:15 -0800
Message-ID: <20170222071413.GA85829@ast-mbp.thefacebook.com>
References: <148760491056.17885.7344022207445355578.stgit@firesoul>
 <58AB11EE.4050905@iogearbox.net>
 <20170220172558.3de0742d@redhat.com>
 <20170221080609.GA42330@ast-mbp.thefacebook.com>
 <20170221140013.76afb3c2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Daniel Borkmann <borkmann@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34346 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbdBVHOT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 02:14:19 -0500
Received: by mail-pg0-f68.google.com with SMTP id s67so843783pgb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 23:14:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170221140013.76afb3c2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 02:00:13PM +0100, Jesper Dangaard Brouer wrote:
> On Tue, 21 Feb 2017 00:06:11 -0800
> Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> > On Mon, Feb 20, 2017 at 05:25:58PM +0100, Jesper Dangaard Brouer wrote:
> > > On Mon, 20 Feb 2017 16:57:34 +0100
> > > Daniel Borkmann <daniel@iogearbox.net> wrote:
> > >   
> > > > On 02/20/2017 04:35 PM, Jesper Dangaard Brouer wrote:  
> > > > > It is confusing users of samples/bpf that exceeding the resource
> > > > > limits for RLIMIT_MEMLOCK result in an "Operation not permitted"
> > > > > message.  This is due to bpf limits check return -EPERM.
> > > > >
> > > > > Instead return -ENOMEM, like most other users of this API.
> > > > >
> > > > > Fixes: aaac3ba95e4c ("bpf: charge user for creation of BPF maps and programs")
> > > > > Fixes: 6c9059817432 ("bpf: pre-allocate hash map elements")
> > > > > Fixes: 5ccb071e97fb ("bpf: fix overflow in prog accounting")    
> > > > 
> > > > Btw, last one just moves the helper so fixes doesn't really apply
> > > > there, but apart from that this is already uapi exposed behavior
> > > > like this for ~1.5yrs, so unfortunately too late to change now. I
> > > > think the original intention (arguably confusing in this context)
> > > > was that user doesn't have (rlimit) permission to allocate this
> > > > resource.  
> > > 
> > > This is obviously confusing end-users, thus it should be fixed IMHO.  
> > 
> > I don't think it's confusing and I think EPERM makes
> > the most sense as return code in such situation.
> 
> Most other kernel users return ENOMEM.

the places in the kernel that check for memlock are not fully consistent.

perf does this:
  lock_limit = rlimit(RLIMIT_MEMLOCK);
  lock_limit >>= PAGE_SHIFT;
  locked = vma->vm_mm->pinned_vm + extra;

  if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
          !capable(CAP_IPC_LOCK)) {
          ret = -EPERM;
          goto unlock;
  }

and in bpf land we got an idea of using memlock limit from perf.

> Documented it here:
>  https://prototype-kernel.readthedocs.io/en/latest/bpf/troubleshooting.html

Thanks! Looks good.
