From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Sockets inside the kernel or userspace ?
Date: Fri, 30 Jun 2006 11:57:49 +0400
Message-ID: <20060630075749.GA30936@2ka.mipt.ru>
References: <e1e1d5f40606300032t7162e165qaa915658e0a71386@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42155 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751448AbWF3H5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 03:57:42 -0400
To: Daniel Bonekeeper <thehazard@gmail.com>
Content-Disposition: inline
In-Reply-To: <e1e1d5f40606300032t7162e165qaa915658e0a71386@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 03:32:28AM -0400, Daniel Bonekeeper (thehazard@gmail.com) wrote:
> Let's suppose that I'm writing a experimental distributed filesystem
> that needs to open a TCP socket to another machines on the LAN, keep a
> pool of connections and be always aware of new data arriving (like a
> userspace select()). What's the best approach to implement this ? Is
> it better to keep all the TCP socket stuff in userspace and use an
> interface like netlink to talk with it ? Or, since we're talking about
> a filesystem (where performance is a must), is it better to keep it in
> kernel mode ?

It depends on your design.
NFS uses in-kernel sockets, but userspace can easily fill 1Gbit link too.
FS must eliminate as much coping as possible, but without deep digging 
into the socket code you will get copy both in kernelspace (one copy 
from socket queue into you buffer) and userspace (the same copy, but 
using slower copy_to_user(), depending on the size of each copy it can 
make noticeble difference), but with kernel socket you get your data 
in the fs/vfs cache already, but with userspace you must copy it back 
into the kernel using slow copy_from_user(), but if data is supposed to
be somehow (heavily) processed before reaching the harddrive (for
example compressed or encrypted), cost of processing can fully hide cost
of the copy itself, so userspace is much more preferable in that
situation due to it's much more convenient development process.

-- 
	Evgeniy Polyakov
