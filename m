From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH net-drivers-2.6 5/6] e100: Performance optimizations to e100 Tx Path
Date: Thu, 21 Apr 2005 11:59:28 -0700
Message-ID: <C925F8B43D79CC49ACD0601FB68FF50C03B1A474@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>,
        "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Scott Feldman" <sfeldma@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Scott Feldman
>On Apr 19, 2005, at 10:50 PM, Malli Chilakala wrote:
>
>> Performance optimizations to e100 Tx Path
>
>So what is the net performance improvement with these changes?

A massive drop in the number of transmit interrupts per second (yielding
more cpu) when sending lots of frames (like forwarding).  I don't
remember my data specifically (stoopid brain). 

>> -	nic->tx_command = cpu_to_le16(cb_tx | cb_i | cb_tx_sf |
>> -		((nic->mac >= mac_82558_D101_A4) ? cb_cid : 0));
>> +	/* no interrupt for every tx completion, delay = 256us 
>if not 557*/
>> +	nic->tx_command = cpu_to_le16(cb_tx | cb_tx_sf |
>> +		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));
>
>Where is this 256us delay coming from?

Turning off the 'I' bit allows the transmit interrupt moderation to come
on, and setting the cid (which was already set) to all 1's indicates the
max delay (256 us)


>>  	/* Template for a freshly allocated RFD */
>>  	nic->blank_rfd.command = cpu_to_le16(cb_el);
>> @@ -1289,12 +1294,15 @@ static inline void e100_xmit_prepare(str
>>  	struct sk_buff *skb)
>>  {
>>  	cb->command = nic->tx_command;
>> +	/* interrupt every 16 packets regardless of delay */
>> +	if((nic->cbs_avail & ~15) == nic->cbs_avail) 
>cb->command |= cb_i;
>
>You messed up Big Endian.

Yes, I did.  Doh.  

>So you send out 15 packets with no i-bit set.  Then what?  No 
>interrupt 
>means no NAPI means no cleanup of those 15 packet skbs.

This doesn't mean what you said.  The i-bit setting every 15 is an
optimization for minimzing latency. i-bit means interrupt immediately
ignoring cid delay.

This means every packet gets worst case a 256us delay before interrupt.
If a receive or watchdog fires the interrupt they will get cleaned up
sooner.
