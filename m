From: WeipingPan <panweiping3@gmail.com>
Subject: Re: [PATCH][RFC] bonding: delete migrated IP addresses from the rlb
 hash table
Date: Thu, 01 Mar 2012 11:58:51 +0800
Message-ID: <4F4EF3FB.8080507@gmail.com>
References: <20120227173400.GB816@midget.suse.cz> <14150.1330567940@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, Andy Gospodarek <andy@greyhouse.net>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45054 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661Ab2CAEBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 23:01:41 -0500
Received: by pbcup15 with SMTP id up15so376970pbc.19
        for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 20:01:41 -0800 (PST)
In-Reply-To: <14150.1330567940@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2012 10:12 AM, Jay Vosburgh wrote:
> Jiri Bohac<jbohac@suse.cz>  wrote:
>
>> Bonding in balance-alb mode records information from ARP packets
>> passing through the bond in a hash table (rx_hashtbl).
>>
>> At certain situations (e.g. link change of a slave),
>> rlb_update_rx_clients() will send out ARP packets to update ARP
>> caches of other hosts on the network to achieve RX load balancing.
>>
>> The problem is that once an IP address is recorded in the hash
>> table, it stays there indefinitely [1]. If this IP address is
>> migrated to a different host in the network, bonding still sends
>> out ARP packets that poison other systems' ARP caches with
>> invalid information.
>>
>> This patch solves this by looking at all incoming ARP packets,
>> and checking if the source IP address is one of the source
>> addresses stored in the rx_hashtbl. If it is, the corresponding
>> hash table entries are removed. Thus, when an IP address is
>> migrated, the first ARP broadcast by its new owner will purge the
>> offending entries of rx_hashtbl.
>>
>>   (a simpler approach, where bonding would monitor IP address
>>    changes on the local system does not work for setups like:
>>    HostA --- NetworkA --- eth0-bond0-br0 --- NetworkB --- hostB
>>    and an IP address migrating from HostB to HostA)
>>
>> The hash table is hashed by ip_dst. To be able to do the above
>> check efficiently (not walking the whole hash table), we need a
>> reverse mapping (by ip_src).
>>
>> I added three new members in struct rlb_client_info:
>>    rx_hashtbl[x].reverse_first will point to the start of a list of
>>       entries for which hash(ip_src) == x.
>>    The list is linked with reverse_next and reverse_prev.
>>
>> When an incoming ARP packet arrives at rlb_arp_recv()
>> rlb_purge_src_ip() can quickly walk only the entries on the
>> corresponding lists, i.e. the entries that are likely to contain
>> the offending IP address.
> 	I've done some initial testing with this, and so far I'm seeing
> one problem: every time the local host (with bonding) sends a broadcast
> ARP, that ends up flushing the entire RLB table.  Well, all entries that
> match the IP on the bond that's sending an ARP request, which is just
> one address in my testing.
>
> 	Anyway, this happens because the switch forwards the broadcast
> ARP back around to one of the other bond slaves, and then that
> "incoming" ARP bears an ip_src of our already-in-use IP address, and
> that matches everything in the table.
>
> 	So, yes, this does work to flush entries out of the table using
> a particular IP source address, but as a practical matter the false
> positives will vastly outnumber the valid hits.  Yes, the table will
> repopulate itself, but that does have some cost if, e.g., flows bounce
> around from one interface to another.  How often this happens would be a
> function of how often the bond has to ARP for an unknown address (i.e.,
> send a broadcast ARP).
>
> 	Perhaps a check that the ip_src being flushed is not actually in
> use locally is warranted?
>
> 	-J
How about just deleting these rlb entries when we receive the events 
that the ip address is deleted ?
Then we need not to montor all arp requests.
Patch is to be followed.

thanks
Weiping Pan
