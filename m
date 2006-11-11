From: Jonathan Day <imipak@yahoo.com>
Subject: Re: Questions regarding network drivers
Date: Sat, 11 Nov 2006 15:21:17 -0800 (PST)
Message-ID: <454688.85582.qm@web31512.mail.mud.yahoo.com>
References: <20061111115449.GA22586@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31512.mail.mud.yahoo.com ([68.142.198.141]:54165 "HELO
	web31512.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1754899AbWKKXVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Nov 2006 18:21:18 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061111115449.GA22586@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> You can use netchannels, which were designed for
> exactly that kind of
> load.

Actually, netchannels are a mechanism I've been
looking at intensely, as a way to simplify this and
keep it sane, without loosing performance.

> You need to process some headers anyway - to select
> appropriate socket
> or netchannel or whatever.

I was planning on cheating there. I've revised the
method slightly, based on previous comments, so that
I'm now doing the following:

The master table has a set of pointers to tables. One
group, one table - for groups in use. Unused groups
have no associated table and the pointer is null.
Pointers are always at (group number * pointer size)
from the start of the table. There's a max of 4096
groups in this system, or the hardware guys start
shooting.

Each group has a table that contains a set of pointers
to buffers. Offset is always (node number * pointer
size). Nodes that are active members have pointers to
pinned, allocated and cleaned buffers. Nodes that
aren't members get null pointers. There are 32 nodes
in the current system.

The packet header contains the group address at a
fixed offset and the source node number at another
fixed offset. The hardware can then grab these and do
the necessary calculations. The hardware has a DMA
controller which can get the group pointer from the
master table then get the buffer pointer from the
group table.

(Essentially, I'm mimicking a primitive virtual memory
system here.)

The hardware then stores enough packet payloads to
fill one page of memory (unless it gets an
end-of-transmit signal before then) and then DMAs the
page of data into the physical page in one shot.
(Since I did the original design, I worked out that
there's too much overhead in setting up a transmit to
just do a single packet at a time.) The hardware is
apparently smart enough to re-order packers if they
come in out of sequence and to NACK anything that's
missing.

Once a page has been filled, the driver simply pushes
the pointer onto a queue and then grabs a pointer to a
fresh page.


Based on what I'm hearing, I'll probably finish this
driver simply to see what it does and post it up -
it'll have educational value, whatever happens. I'll
also work on a netchannels version which is less
hardware-specific and more "normal".

> > I can try getting beer. Oregon has some acceptable
> > microbreweries, but I miss having a pint of
> Hatters in
> > England. Mead is easier. I brew mead. Strong, dry,
> > rocket-fuel mead.
> 
> Then you definitely just need to send your driver to
> netdev@.

Sounds good to me. Liquid driver review aids will be prepared.


 
____________________________________________________________________________________
Do you Yahoo!?
Everyone is raving about the all-new Yahoo! Mail beta.
http://new.mail.yahoo.com
