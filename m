From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip route: Make name of protocol 0 consistent
Date: Mon, 6 Feb 2017 16:03:35 -0700
Message-ID: <5f55d6bb-ef2e-dbb0-c677-006964f1b7fe@cumulusnetworks.com>
References: <1486056126-23900-1-git-send-email-dsa@cumulusnetworks.com>
 <20170206140107.41569a73@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33058 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751502AbdBFXDm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 18:03:42 -0500
Received: by mail-pg0-f49.google.com with SMTP id 204so32279045pge.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 15:03:42 -0800 (PST)
In-Reply-To: <20170206140107.41569a73@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/17 3:01 PM, Stephen Hemminger wrote:
> On Thu,  2 Feb 2017 09:22:06 -0800
> David Ahern <dsa@cumulusnetworks.com> wrote:
> 
>> iproute2 can inconsistently show the name of protocol 0 if a route with
>> a custom protocol is added. For example:
>>   dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
>>   local ::1 dev lo  table local  proto none  metric 0  pref medium
>>   local fe80::225:90ff:fecb:1c18 dev lo  table local  proto none  metric 0  pref medium
>>   local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto none  metric 0  pref medium
>>
>> protocol 0 is pretty printed as "none". Add a route with a custom protocol:
>>   dsa@cartman:~$ sudo ip -6 ro add  2001:db8:200::1/128 dev eth0 proto 123
>>
>> And now display has switched from "none" to "unspec":
>>   dsa@cartman:~$ ip -6 ro ls table all | egrep 'proto none|proto unspec'
>>   local ::1 dev lo  table local  proto unspec  metric 0  pref medium
>>   local fe80::225:90ff:fecb:1c18 dev lo  table local  proto unspec  metric 0  pref medium
>>   local fe80::92e2:baff:fe5c:da5d dev lo  table local  proto unspec  metric 0  pref medium
>>
>> The rt_protos file has the id to name mapping as "unspec" while
>> rtnl_rtprot_tab[0] has "none". The presence of a custom protocol id
>> triggers reading the rt_protos file and overwriting the string in
>> rtnl_rtprot_tab. All of this is logic from 2004 and earlier.
>>
>> The simplest change to achieve consistency is to update the rt_protos
>> file to use "none" instead of "unspec".
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>  etc/iproute2/rt_protos | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/etc/iproute2/rt_protos b/etc/iproute2/rt_protos
>> index 82cf9c46cf6f..21af85b9d7e1 100644
>> --- a/etc/iproute2/rt_protos
>> +++ b/etc/iproute2/rt_protos
>> @@ -1,7 +1,7 @@
>>  #
>>  # Reserved protocols.
>>  #
>> -0	unspec
>> +0	none
>>  1	redirect
>>  2	kernel
>>  3	boot
> 
> This doesn't look like a good solution, you loose the value of unspec.
> 
> Just to clarify. You added a custom protocol value to netlink.
> And then you are using upstream iproute2 source to display the value.

no. I am saying the string displayed for protocol '0' is changing. This
is all within iproute2 code and files; it has 2 strings for protocol 0:

lib/rt_names.c:
static char *rtnl_rtprot_tab[256] = {
        [RTPROT_UNSPEC]   = "none",

and the rt_protos file above shows "unspec"

The presence of a custom protocol triggers the rt_protos file to be read:

const char *rtnl_rtprot_n2a(int id, char *buf, int len)
{
        if (id < 0 || id >= 256) {
                snprintf(buf, len, "%u", id);
                return buf;
        }
        if (!rtnl_rtprot_tab[id]) {
                if (!rtnl_rtprot_init)
                        rtnl_rtprot_initialize();


Reading the file changes the string in rtnl_rtprot_tab for
RTPROT_UNSPEC. Both string values -- "none" and "unspec" come from
iproute2, so my point is that string is inconsistent within iproute2.
