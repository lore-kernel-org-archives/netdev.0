From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next 04/14] net: Fix issue with netdev_tx_reset_queue not
 resetting queue from XOFF state
Date: Sun, 22 Apr 2012 20:21:17 -0700
Message-ID: <4F94CAAD.1040207@intel.com>
References: <CAKgT0UcZZNOH=D5mJDaw3_6femW120ZG0cBc8Nz=-=8h6X17kg@mail.gmail.com> <CA+mtBx-TJAr-cu-vKYq6m2ZQzn1X1vf+_PKUZXDirnKEF67EAw@mail.gmail.com> <4F92DFF3.2080301@intel.com> <20120421.161842.1097392704709233196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.duyck@gmail.com,
	alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58085 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753121Ab2DWDVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Apr 2012 23:21:19 -0400
In-Reply-To: <20120421.161842.1097392704709233196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/21/2012 1:18 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend@intel.com>
> Date: Sat, 21 Apr 2012 09:27:31 -0700
> 
>> On 4/20/2012 11:01 PM, Tom Herbert wrote:
>>>> I don't recall the exact reason now, as John said I think it had to do
>>>> with the ethtool tests not using the same cleanup routine and leaving
>>>> us in a bad state.  I am pretty sure there was some path in which
>>>> where the call was didn't work but I do not recall the exact details
>>>> now.  Most of the reason for moving it is due to the fact that the
>>>> reset is now also clearing the bit, and from the driver perspective we
>>>> didn't need it in two places.  After looking it all over again, I
>>>> suppose this causes a cosmetic issue for the bql "inflight" statistic
>>>> in sysfs since the value will be retained until the interface is
>>>> brought back up with this change.  Is that an issue or something that
>>>> can be lived with since the interface isn't active anyway in this
>>>> case?
>>>>
>>> On the surface, it seems cleaner and probably a simpler convention to
>>> clear the state when the buffers are being freed.  If there's a good
>>> reason not to do this for igb, it makes me wonder if this should be
>>> done the same way in other drivers...
>>>
>>> Tom
>>
>> Just dug up the old thread. This was to fix a bug that byte queue limits
>> was causing with some of the loopback tests evoked from ethtool. The
>> loopback test uses a separate path to free the buffers which wasn't
>> calling netdev_tx_reset_queue().
>>
>> We should likely just explicitly clear the state in each routine rather
>> than try to be clever IMO.
> 
> Agreed.

Further it can cause a real bug (the qdisc stack bit doesn't get cleared) if
the real_num_tx_queues is decreased for example in ixgbe when DCB is disabled.
I'll send a patch to JeffK.

Thanks,
John
