From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] iproute2: bridge: support vlan range
Date: Sun, 18 Jan 2015 01:11:54 -0800
Message-ID: <54BB78DA.6060208@cumulusnetworks.com>
References: <1421391147-35021-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bA2VHepe8CCYuubH8teXMvRry10jnpsisYq+7Qv+gXzHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:52698 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbbARJL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 04:11:56 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so30779742pdj.0
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 01:11:55 -0800 (PST)
In-Reply-To: <CAE4R7bA2VHepe8CCYuubH8teXMvRry10jnpsisYq+7Qv+gXzHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/15, 5:35 PM, Scott Feldman wrote:
> On Thu, Jan 15, 2015 at 10:52 PM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds vlan range support to bridge command
>> using the newly added vinfo flags BRIDGE_VLAN_INFO_RANGE_BEGIN and
>> BRIDGE_VLAN_INFO_RANGE_END.
>>
>> $bridge vlan show
>> port    vlan ids
>> br0      1 PVID Egress Untagged
>>
>> dummy0   1 PVID Egress Untagged
>>
>> $bridge vlan add vid 10-15 dev dummy0
>> port    vlan ids
>> br0      1 PVID Egress Untagged
>>
>> dummy0   1 PVID Egress Untagged
>>           10
>>           11
>>           12
>>           13
>>           14
>>           15
>>
>> $bridge vlan del vid 14 dev dummy0
>>
>> $bridge vlan show
>> port    vlan ids
>> br0      1 PVID Egress Untagged
>>
>> dummy0   1 PVID Egress Untagged
>>           10
>>           11
>>           12
>>           13
>>           15
>>
>> $bridge vlan del vid 10-15 dev dummy0
>>
>> $bridge vlan show
>> port    vlan ids
>> br0      1 PVID Egress Untagged
>>
>> dummy0   1 PVID Egress Untagged
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> ---
>>   bridge/vlan.c             |   46 ++++++++++++++++++++++++++++++++++++++-------
>>   include/linux/if_bridge.h |    2 ++
>>   2 files changed, 41 insertions(+), 7 deletions(-)
>>
>> diff --git a/bridge/vlan.c b/bridge/vlan.c
>> index 3bd7b0d..90b3b6b 100644
>> --- a/bridge/vlan.c
>> +++ b/bridge/vlan.c
>> @@ -32,6 +32,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
>>          } req;
>>          char *d = NULL;
>>          short vid = -1;
>> +       short vid_end = -1;
>>          struct rtattr *afspec;
>>          struct bridge_vlan_info vinfo;
>>          unsigned short flags = 0;
>> @@ -49,8 +50,18 @@ static int vlan_modify(int cmd, int argc, char **argv)
>>                          NEXT_ARG();
>>                          d = *argv;
>>                  } else if (strcmp(*argv, "vid") == 0) {
>> +                       char *p;
>>                          NEXT_ARG();
>> -                       vid = atoi(*argv);
>> +                       p = strchr(*argv, '-');
>> +                       if (p) {
>> +                               *p = '\0';
>> +                               p++;
>> +                               vinfo.vid = atoi(*argv);
>> +                               vid_end = atoi(p);
> Is "vid 10-" same as "vid 10-0"?
correct ..

# bridge vlan add vid 10- dev dummy0
Invalid VLAN range "10-0"

>
> Is "vid -15" same as "vid 0-15"?
correct

# bridge vlan add vid -10 dev dummy0
root@net-next:~/iproute2# bridge vlan show
port    vlan ids
br0     1 PVID Egress Untagged

dummy0     0 PVID
      1
      2
      3
      4
      5
      6
      7
      8
      9
      10

dummy1     1 PVID Egress Untagged

maybe vlan 0 should not be allowed. Will check

>
> What is "vid -"?
>
> Does the "-" char mess up shells?  I don't know the answer; just asking.
No it does not :)

# bridge vlan add vid -
Device and VLAN ID are required arguments.

>
>> +                               vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_BEGIN;
>> +                       } else {
>> +                               vinfo.vid = atoi(*argv);
>> +                       }
>>                  } else if (strcmp(*argv, "self") == 0) {
>>                          flags |= BRIDGE_FLAGS_SELF;
>>                  } else if (strcmp(*argv, "master") == 0) {
>> @@ -67,7 +78,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
>>                  argc--; argv++;
>>          }
>>
>> -       if (d == NULL || vid == -1) {
>> +       if (d == NULL || vinfo.vid == -1) {
> Where was vinfo.vid initialized to -1?  Maybe use vid rather than
> vinfo.vid in the code above where parsing the arg, and continue using
> vid and vid_end until final put of vinfo.
>
There is already a "memset(&vinfo, 0, sizeof(vinfo));"  in the code in 
the beginning of the function.
And the code is already using vinfo for flags. That's the reason i 
decided to use vinfo here.

Thanks,
Roopa
