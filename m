From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [3/3] POHMELFS high performance network filesystem.
Date: Sun, 15 Jun 2008 13:14:08 +0400
Message-ID: <20080615091407.GA4468@2ka.mipt.ru>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164241.GC26166@2ka.mipt.ru> <19f34abd0806150047w4338502en9a75681fb0c95438@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19f34abd0806150047w4338502en9a75681fb0c95438@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vegard.

On Sun, Jun 15, 2008 at 09:47:03AM +0200, Vegard Nossum (vegard.nossum@gmail.com) wrote:
> I'm having a hard time convincing myself that the error handling here
> is correct. You have this kind of setup:
> 
> 1. for each config in config list {
>     2. for each config in superblock state list {
>         pohmelfs_config_eql();
>         ...
>     }
> }
> 
> And according to your code, if pohmelfs_config_eql returns non-zero in
> the last iteration of #1, then -EEXISTS will be the return value of
> the whole function (but the config _will_ be copied; it is not undone
> in this case). But if pohmenlfs_config_eql returns non-zero in any but
> the last iteration of #1, then 0 will be the return value. Is this
> your intention?

Task of this function is to copy as much new configs added by user (or
by remote server) as we can. 
If config already exists (was copied in previous iterations) we skip it.
If it does not, we allocate new structure and initialize it. If
allocation fails, it is a serious error and unlikely we want to proceed,
so we jump out of the loop and drop all states and return error. If we
just failed to initialie new state (like connection was refused by
remote server), we simply drop that failed case and proceed further. In
theory we still can leave that half-initialized states in the list, and
any attempt to send request via them will try to initialize its network
part, but thread creation and allocation itself will be tried to
recover, so I just drop such state here. I think initialization function
should not return error if it failed to connect or create a socket,
since it can/will be recovered later if needed.

We should not return eexist, from non-error label, but at the only
place, where this return value is checked (mount time initialization),
superblock list is empty and thus this error can not happen.

-- 
	Evgeniy Polyakov
