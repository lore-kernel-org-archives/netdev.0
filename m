From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] meta ematch
Date: Fri, 14 Jan 2005 02:13:40 +0100
Message-ID: <41E71CC4.3020102@trash.net>
References: <20050105144514.GQ26856@postel.suug.ch> <1105019225.2312.7.camel@jzny.localdomain> <20050106194102.GW26856@postel.suug.ch> <1105105511.1046.77.camel@jzny.localdomain> <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain> <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain> <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net> <20050113192047.GQ26856@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050113192047.GQ26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>* Patrick McHardy <41E6C3E5.2020908@trash.net> 2005-01-13 19:54
>
>  
>
>>Looks great. I have a few doubts about about the set of chosen values
>>though. Things like nf_debug and nf_cache were never meant to be
>>userspace-visible. What about backwards compatibility if we want to
>>remove it, or some other more meaningful value where just returning 0
>>wouldn't be the same ?
>>    
>>
>
>It is indeed problematic and they should be marked as "for debugging
>purposes (unreliable)" but at least nf_debug and nfctinfo are
>very useful for debugging.
>
True. nfctinfo is even useful for more, the direction of a connection
might be interesting. connmark, conntrack counters, src-ip before SNAT
etc. might also be interesting, but they are horrible to implement cleanly
because any dependency on ip_conntrack_lock will automatically load
ip_conntrack. Perhaps we should add something like nf_ct_get_afinfo() to
return a set of conntrack operations to nf_conntrack.

For things beside the nf* fields: I think we should make it very clear
that everything that isn't already visible to userspace in some way, and
thus won't disappear (like priority, nfmark, load average ...), can get
changed/removed any time.

>>- var_dev sets dst->value to dev->name, meta_var_destroy will try to
>> free dev->name.
>>    
>>
>
>The `dst` meta_value is the l_value/r_lvalue from em_meta_match and
>never gets destroyed. I reused meta_data to store address & length.
>It might be a good idea to make a new struct for this to make it
>more readable though.
>
Looks good to me already. I only looked at the diff, so I didn't really
follow the codepath.

>>- meta_int_change only uses 32 bit, but dst->value is unsigned long
>> (64 bit on 64-bit arches). nfmark for example is unsigned long, so
>> you should also use *(unsigned long *).
>>    
>>
>
>Doesn't work when size of long differs between kernel and userspace.
>I'm aware of this but it seems everyone is using int anyway for nfmark,
>so yes this indeed limits the use of nfmark match to only 32 bits
>on 64bit machines. The proper way is to introduce a new type
>TCF_EM_TYPE_INT64 and access nfmark over it but I didn't want to
>create a new type just because of this special case. We can always
>add it later as addition to the 32bit version.
>  
>
Shouldn't be too hard to get right. In the kernel you can decide based
on RTA_PAYLOAD. Userspace needs some other way to notice it is running
as a 32-bit binary on a 64-bit kernel, but that's something you can't
solve in the kernel anyway.

Regards
Patrick
