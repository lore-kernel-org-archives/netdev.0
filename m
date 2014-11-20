From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix connect() invalid -EADDRNOTAVAIL error
Date: Wed, 19 Nov 2014 22:33:09 -0800
Message-ID: <1416465189.8629.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416379060-15685-1-git-send-email-jmaxwell37@gmail.com>
	 <1416417120.14060.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAGHK07BrUmWxbNA3FzYtEqUOji_qn816=dmi_J40S_CKE3kMnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet <kuznet@ms2.inr.ac.ru>,
	jmorris <jmorris@namei.org>, yoshfuji <yoshfuji@linux-ipv6.org>,
	kaber <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jon Maxwell <jmaxwell@redhat.com>
To: Jonathan Maxwell <jmaxwell37@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGHK07BrUmWxbNA3FzYtEqUOji_qn816=dmi_J40S_CKE3kMnA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-11-20 at 14:44 +1100, Jonathan Maxwell wrote:
> > > Prerequisites for this to happen:
> > > 1) The local tcp port range must be exhausted.
> > > 2) A process must have called bind() followed by connect() for all
> > > local ports.
> > 
> > How the bind() is done exactly ? How SO_REUSEADDR is used ?
> 
> It fails regardless. I tried both with and without for the client and
> server programs.
> 

This is the missing part from the programs.

By not using SO_REUSEADDR, programs basically do not allow another
programs to use same port.

> But removing the bind() and just calling connect() from the initial
> program
> then a subsequent connect() from a separate program succeeds. It seems
> that 
> this is inconsistent behaviour. The proposed fix makes it behave the
> same for
> 
> both cases.

This not consistent behavior is well known and somehow expected by some
applications.

bind() requests the kernel that this socket has a reserved port.

It means the socket can later disconnect from the target, and reconnect
to another, using _same_ source port, or chose to listen() on this port.

That is why kernel is so picky, otherwise the listen() might fail
later...

This is part of BSD socket semantic.

You have to use SO_REUSEADDR on both programs to relax these
constraints.

Your change might break existing programs, really expecting kernel
to behave as requested.
