From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Fri, 12 Oct 2012 23:17:57 +0800
Message-ID: <CACVXFVOChR3ZJSyjo44AMwzzjx5URWvEe25KY2eV5evJpF9D+g@mail.gmail.com>
References: <Pine.LNX.4.44L0.1210111030570.1170-100000@iolanthe.rowland.org>
	<3535515.7NRjKhCcrL@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern@rowland.harvard.edu>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org, jkosina@suse.com
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60157 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303Ab2JLPSA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 11:18:00 -0400
In-Reply-To: <3535515.7NRjKhCcrL@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 9:51 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Thursday 11 October 2012 10:36:22 Alan Stern wrote:
>
>> It's worse than you may realize.  When a SCSI disk is suspended, all=
 of
>> its ancestor devices may be suspended too.  Pages can't be read in f=
rom
>> the drive until all those ancestors are resumed.  This means that al=
l
>> runtime resume code paths for all drivers that could be bound to an
>> ancestor of a block device must avoid GFP_KERNEL.  In practice it's
>> probably easiest for the runtime PM core to use tsk_set_allowd_gfp()
>> before calling any runtime_resume method.
>>
>> Or at least, this will be true when sd supports nontrivial autosuspe=
nd.
>
> Up to now, I've found three driver for which tsk_set_allowd_gfp() wou=
ldn't
> do the job. They boil down into two types of errors. That is surprisi=
ngly good.

Looks all are very good examples, :-)

>
> First we have workqueues. bas-gigaset is a good example.
> The driver kills a scheduled work in pre_reset(). If this is done syn=
chronously
> the driver may need to wait for a memory allocation inside the work.
> In principle we could provide a workqueue limited to GFP_NOIO. Is tha=
t worth
> it, or do we just check?

The easiest way is to always call tsk_set_allowd_gfp(~GFP_IOFS) in the
start of work function under the situation, and restore the flag in the=
 end
of the work function.

>
> Second there is a problem just like priority inversion with realtime =
tasks.
> usb-skeleton and ati_remote2
> They take mutexes which are also taken in other code paths. So the er=
ror
> handler may need to wait for a mutex to be dropped which can only hap=
pen
> if a memory allocation succeeds, which is waiting for the error handl=
er.

Suppose mutex_lock(A) is called in pre_reset(), one solution is that
always calling tsk_set_allowd_gfp(~GFP_IOFS) before each mutex_lock(A).
We can do it only for devices with storage interface in current
configuration.


Thanks=EF=BC=8C
--
Ming Lei
