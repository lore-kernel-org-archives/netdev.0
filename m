From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test4-mm6: locking imbalance with rtnl_lock/unlock?
Date: Sat, 6 Sep 2003 18:47:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030906184715.38bf70d9.akpm@osdl.org>
References: <1062885603.24475.7.camel@ixodes.goop.org>
	<20030906222436.GB15327@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, linux-kernel@vger.kernel.org, bos@serpentine.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20030906222436.GB15327@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton Blanchard <anton@samba.org> wrote:
>
> 
> > which is SIOCGIFADDR.  It seems to me the down() is actually the
> > rtnl_lock() called at net/ipv4/devinet.c:536 in devinet_ioctl.  This
> > happens even when netplugd is no longer running.  It looks like someone
> > isn't releasing the lock.
> > 
> > I'm going over all the uses of rtnl_lock() to see if I can find a
> > problem, but no sign yet.  I wonder if someone might have broken this
> > recently: I'm running 2.6.0-test4-mm6, but I think Bryan is running an
> > older kernel (2.6.0-test4?), and hasn't seen any problems.
> 
> Yep I saw this too when updating from test2 to BK from a few days ago.
> >From memory the cpu that had the rtnl_lock was stuck in dev_close,
> probably netif_poll_disable. I got side tracked and wasnt able to look
> into it.

If the caller of netif_poll_disable() has a signal pending,
netif_poll_disable() becomes a busy loop, which might be causing a
lockup.  Probably not, but it needs to use TASK_UNINTERRUPTIBLE.

I doubt if that explains Jeremy's deadlock though...
