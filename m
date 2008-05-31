From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH BUGFIX -rc4] Smack: Respect 'unlabeled' netlabel mode
Date: Sat, 31 May 2008 03:58:26 +0300
Message-ID: <20080531005826.GA6945@ubuntu>
References: <20080530233603.GA2994@ubuntu> <538684.41302.qm@web36603.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>,
	linux-security-module@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <538684.41302.qm@web36603.mail.mud.yahoo.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Casey,

On Fri, May 30, 2008 at 04:10:37PM -0700, Casey Schaufler wrote:
> 
> 
> To date the behavior of a Smack system running with nltype
> unlabeled has been carefully undefined. 
>

In the early days (before the 'Smack: unlabeled outgoing ambient packets'
patch - 4bc87e62), I used '$ echo unlabeled > /smack/nltype' in my startup 
scripts to avoid sending cipso-affected packets. When I upgraded this 
machine's kernel, I faced the -EPERM problem mentiond above. 

> The way you're defining
> it will result in a system in which only processes running with
> the ambient label will be able to use sockets, unless I'm reading
> the code incorrectly. 

I've tried to see the relation but failed, any help?

I'm noticing the opposite though, without defining nltype=unlabeled, 
we're forcing every smack-labeled process to send cipso-affected 
packets (and usually no machine around understands cipso).

_Assuming_ the concept is accepted, depending on the ambient label
may actually lead to a race condition though:

- A packet is set with the ambient label domain
- Ambient label changes
  - old ambient-label netlabel domain is deleted
  - new ambient-label is set
  - new ambient-label netlabel domain is created
- call netlabel_sock_setattr(), uses the old ambient label, leads
  to the -EPERM problem.
  -- Rare, but can happen

There are two possible solutions in my mind:

- Using a predefined netlabel domain to denote to unlabeled packets.
  Defect: May collide with a user chosen label and used to break security.
  Solution: Use a domain name that can't become a label (Hackery ?)

- I've tried first to use what was done before the 'Smack: unlabeled outgoing 
  ambient packets' patch, which honored nltype=unlabeled, but ignored netlabel
  completely:
  i.e.

  int rc = 0;
  if (secattr.flags != NETLBL_SECATTR_NONE)
       rc = netlbl_sock_setattr(sk, &secattr);
  return rc

  Paul, would this be right from a netlabel perspective ?

-- 
Ahmed S. Darwish
Homepage: http://darwish.07.googlepages.com
Blog: http://darwish-07.blogspot.com

