From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Thu, 2 Oct 2003 19:26:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003022615.GA42593@gaz.sfgoth.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil> <20031001054226.126cea7b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031001054226.126cea7b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Although, unless VCC connect can potentially sleep, it might
> be better to keep exporting the rwlock and take it as a reader
> instead of grabbing the rtnl semaphore.

VCC connect can definately sleep - a good example is
drirvers/usb/misc/speedtch.c but there are probably other ones.

My personal recommendations:
  * There should be a per-atm-device semaphore held across calls into the
    driver's ->open, ->close, ->change_qos and maybe a couple other things
    to serialize those operations (for the sake of keeping the drivers
    sane - there's no reason there should be multiple operations pending)

  * The ATM layer shouldn't need to keep any other sorts of locks across
    calls into atm_dev->open or such.  To avoid race conditions the ATM
    code needs to:
      1. Take whatever internal spinlock it needs
      2. Add the itf/vpi/vci tuple to whatever datastructure we're holding
         the vcc list in - but mark it as "inactive" so we don't find it
	 while others are searching the list.  Obviously the open will
	 fail if we find a matching tuple (whether or not it was active)
      3. Drop the spinlock
      4. Take the per-device semaphore
      5. Call atmdev->open
      6. Drop the per-device semaphore
      7. Re-take the internal spinlock
      8. If open succeeded now mark the vcc as "active".  If the open failed
         just delete it
      9. Drop the internal spinlock

    To do a close the method is similar:
      1. Take the internal spinlock
      2. Find the tuple, mark it as inactive
      3. Drop the spinlock
      4. Take the per-device semaphore
      5. Call atmdev->close
      6. Drop the per-device semaphore
      7. Re-take the internal spinlock
      8. Delete vcc from the list
      9. Drop the internal spinlock

    Then ->open and ->close can sleep like they need to but won't block
    other accesses to the list in the mean time.

  * If ATM_ITF_ANY is a pain to fix it should just be removed - it's
    basically a misfeature and is probably never used by anybody.  I've
    already posted a patch to linux-atm-general that basically does this
    (it changes "ATM_ITF_ANY" to mean "first interface we find")

-Mitch
