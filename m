From: Ben Greear <greearb@candelatech.com>
Subject: Re: local_bh_enable & hard_start_xmit
Date: Mon, 18 Apr 2005 15:59:05 -0700
Message-ID: <42643BB9.6050705@candelatech.com>
References: <42642892.2040300@candelatech.com> <20050418151421.41a8f64a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050418151421.41a8f64a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 18 Apr 2005 14:37:22 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>So, two questions:
>>
>>1)  Why is it bad to have interrupts disabled when calling
>>     the local_bh_enable() method?
> 
> 
> Because it creates a deadlock.  You can always take hard IRQ disabling
> locks inside of BH disabling ones, but _never_ the other way around.
> 
> local_bh_enable() potentially runs BH handlers, and this must occur with
> hard IRQs enabled.

Ok.  It would be great if this explanation was in comments near the warning in the code.
The dev_start_xmit code in dev.c could also have a note mentioning that it
must never be called with IRQs disabled.

>>2)  Should there be a hard requirement that one must never have IRQs disabled
>>     when calling dev->hard_start_xmit  (this requirement seems to currently
>>     be in effect because VLANs can call dev_queue_xmit from their hard_start_xmit
>>     method, and it appears that dev_queue_xmit must not be called with IRQs disabled).
> 
> 
> Yes, it is another true requirement.

This would be a good addition to the Documentation/networking/netdevices.txt
file, or maybe to the dev.c file somewhere (I haven't found an complete list of
locking notes, though the comments in the dev.c file and the netdevices.txt file
are a big help.)

I should be able to fix my particular problem by using reference counting and
breaking up my big loop into smaller work units.

I assume that it is fine to nest calls to local_bh_enable/disable?  (This
seems to be required since you are supposed to have bh disabled when
calling hard_start_xmit, but hard_start_xmit can call dev_queue_xmit which
disables the bh again...)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
