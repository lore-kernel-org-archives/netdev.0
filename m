From: Richard MUSIL <richard.musil@st.com>
Subject: Re: [GENETLINK] some thoughts on the usage
Date: Thu, 16 Aug 2007 10:50:58 +0200
Message-ID: <46C40FF2.2030400@st.com>
References: <46BC25A6.7000703@st.com> <20070815175009.GA32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog13.obsmtp.com ([207.126.144.127]:33440 "EHLO
	s200aog13.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018AbXHPIwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 04:52:14 -0400
In-Reply-To: <20070815175009.GA32236@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Richard MUSIL <richard.musil@st.com> 2007-08-10 10:45
>> I have noticed that although ops for each family are the same (each
>> device is functionally same) I cannot use same genl_ops struct for
>> registration, because it uses internal member to link in list. Therefore
>> it is necessary to allocate new genl_ops for each device and pass it to
>> registration. But I cannot "officially" use this list to track those
>> genl_ops (so I can properly destroy them later), because there is no
>> interface. So I need to redo the management of the structures on my own.
> 
> The intended usage of the interface in your example would be to register
> only one genetlink family, say "tpm", register one set of operations
> and then have an attribute in every message which specifies which TPM
> device to use. This helps keeping the total number of genetlink families
> down.

I got your point. The fact that there are several families of the same
device type seems however quite convenient. For example, I
create/register virtual device /dev/tpm0 and register family with the
same name for that device, the same for /dev/tpm1 etc. Then I got
straightforward association in between devices and families and get for
free the whole management what happen if I try to talk to device which
is not registered/present etc.
I could multiplex it over one channel, but I will need to make the
communication protocol more complex and make me handle all exceptions
myself.
Since in my case there will be probably not more than one device
present, and the device itself is quite "exotic" I would probably not
rewrite it to the multiplexing scheme, but I understand what you mean
and will take it into account next time I face decision how to use
genetlink.

However I am still wondering, whether the allocation of structures
(genl_family, genl_ops) should not be done by genetlink layer instead of
the user (I mean allocating copy of the struct passed by user). This is
for example, what TPM layer (tpm.c) does. This would come at slight cost
at memory usage and performance, but will protect the caller from
inspecting internal behavior and taking care of that. And internal links
would nicely help in keeping of track of allocated structures. I could
write a patch for this.

>> The second "inconvenience" is that for each family I register, I also
>> register basically same ops (basically means, the definitions, and doit,
>> dumpit handlers are same, though the structures are at different
>> addresses for reasons described above). When the handler receives the
>> message it needs to associate the message with the actual device it is
>> handling. This could be done through family lookup (using
>> nlmsghdr::nlmsg_type), but I wondered if it would make sense to extend
>> genl_family for user custom data pointer and then pass this custom data
>> (or genl_family reference) to each handler (for example inside
>> genl_info). It is already parsed by genetlink layer, so it should not
>> slow things down.
> 
> That's not a bad idea, although I think we should try and keep the
> generic netlink part as simple as possible. There is a family specific
> header, referred to as user header in genl_info which is basically
> what you're looking for with the custom header. I believe making the
> generic netlink family aware of anything beyond family id and operations
> id only complicates things.

Ok, this was just an idea ;-) - probably important only for high
performance genetlink users.

Richard
