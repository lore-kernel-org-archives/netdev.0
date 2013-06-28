From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v3 1/2] lib: vsprintf: add IPv4/v6 generic %p[Ii]S[pfs]
 format specifier
Date: Fri, 28 Jun 2013 18:13:52 +0200
Message-ID: <51CDB640.6020504@redhat.com>
References: <1372421131-1672-1-git-send-email-dborkman@redhat.com>  <1372421131-1672-2-git-send-email-dborkman@redhat.com>  <1372434289.29380.6.camel@joe-AO722> <51CDB183.1070209@redhat.com> <1372435479.29380.11.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372435479.29380.11.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/28/2013 06:04 PM, Joe Perches wrote:
> On Fri, 2013-06-28 at 17:53 +0200, Daniel Borkmann wrote:
>> On 06/28/2013 05:44 PM, Joe Perches wrote:
>>> On Fri, 2013-06-28 at 14:05 +0200, Daniel Borkmann wrote:
>>>> In order to avoid making code that deals with printing both, IPv4 and
>>>> IPv6 addresses, unnecessary complicated as for example ...
> []
>>> Should any other include other than net/addrconf be needed?
>> I'm not sure I understand this question.
>
> the #include <net/addrconf.h> indirectly
> includes <linux/in.h> and <linux/in6.h>
> but because this now uses struct sockaddr and family
> it may be more sensible to directly include those.
>
> No worries really, it works now.
>
>>>> +char *ip6_addr_string_sa(char *buf, char *end, const struct sockaddr_in6 *sa,
>>>> +			 struct printf_spec spec, const char *fmt)
>>>> +{
>>> []
>>>> +	char fmt6[2] = { fmt[0], '6'};
>>>
>>> This looks odd to me.  why not use a bool compressed
>>> flag and identify this before the isalpha loop and not
>>> have fmt6 at all?
>>
>> Well, we have a bool called 'have_c' that identifies if 'c' was specified. To have
>> the same behaviour as with %pI6, this is used to create a temporary fmt that we then
>> can pass to ip6_string(). If you look at ip6_addr_string(), it's done the same way,
>
> It's a little different than that.
>
>> and by that, we stay compatible in behaviour.
>
> That's slightly tricky, ip6_addr_string just needs "I" or "i"
>
> But, your implementation, your choice,

Ok, I suggest we leave it as posted.

Just to clarify, as a side note: fmt layout is { '[Ii]', '6', 'c' } where the 'c' is
optional (so fmt[2] can also be 0), but still tested:

static noinline_for_stack
char *ip6_addr_string(char *buf, char *end, const u8 *addr,
		      struct printf_spec spec, const char *fmt)
{
	char ip6_addr[sizeof("xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:255.255.255.255")];

	if (fmt[0] == 'I' && fmt[2] == 'c')
		ip6_compressed_string(ip6_addr, addr);
	else
		ip6_string(ip6_addr, addr, fmt);

	return string(buf, end, ip6_addr, spec);
}

In the patch, those conditions are respected as well.

Thanks,

Daniel
