From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: vlan tagged packets and libpcap breakage
Date: Tue, 11 Dec 2012 16:46:05 -0800
Message-ID: <CAOxq_8PRGWh86oqvxqvPEqmW1TN+0ztNzhczbTqfHKeOinozzQ@mail.gmail.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com>
	<3246.1351717319@obiwan.sandelman.ca>
	<CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com>
	<87mwyi9h1x.fsf@xmission.com>
	<alpine.OSX.2.00.1212111432430.78903@animac.local>
	<1355267060.27891.139.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francesco Ruggeri <fruggeri@aristanetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	tcpdump-workers@lists.tcpdump.org, Michael Richardson <mcr@sandelman.ca>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <tcpdump-workers-bounces@lists.tcpdump.org>
In-Reply-To: <1355267060.27891.139.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.sandelman.ca/mailman/options/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=unsubscribe>
List-Archive: <http://lists.sandelman.ca/pipermail/tcpdump-workers>
List-Post: <mailto:tcpdump-workers@lists.tcpdump.org>
List-Help: <mailto:tcpdump-workers-request@lists.tcpdump.org?subject=help>
List-Subscribe: <https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers>,
	<mailto:tcpdump-workers-request@lists.tcpdump.org?subject=subscribe>
Sender: tcpdump-workers-bounces@lists.tcpdump.org
Errors-To: tcpdump-workers-bounces@lists.tcpdump.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 11, 2012 at 3:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-12-11 at 14:36 -0800, Ani Sinha wrote:
>> >
>> > It is possible to test for the presence of support of the new vlan bpf
>> > extensions by attempting to load a filter that uses them.  As only valid
>> > filters can be loaded, old kernels that do not support filtering of vlan
>> > tags will fail to load the a test filter with uses them.
>>
>> Unfortunately I do not see this. The sk_chk_filter() does not have a
>> default in the case statement and the check will not detect an unknown
>> instruction. It will fail when the filter is run and as far as I can see,
>> the packet will be dropped. Something like this might help?
>>
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index c23543c..96338aa 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -548,6 +548,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>>                       return -EINVAL;
>>               /* Some instructions need special checks */
>>               switch (code) {
>> +             /* for unknown instruction, return EINVAL */
>> +             default : return -EINVAL;
>>               case BPF_S_ALU_DIV_K:
>>                       /* check for division by zero */
>>                       if (ftest->k == 0)
>
> This patch is wrong.


yes I generated this patch wrong.

>
> Check lines 546, 547, 548 where we do the check for unknown instructions
>
> code = codes[code];
> if (!code)
>         return -EINVAL;

yepph it's OK here.

>
> If you want to test ANCILLARY possible values, its already too late, as
> old kernels wont use any patch anyway.

yepph, I was looking at possible ancilliary values. Basically this
case statement :

#define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:        \
                                code = BPF_S_ANC_##CODE;        \
                                break
                        switch (ftest->k) {
                        ANCILLARY(PROTOCOL);
                        ANCILLARY(PKTTYPE);
                        ANCILLARY(IFINDEX);
                        ANCILLARY(NLATTR);
                        ANCILLARY(NLATTR_NEST);
                        ANCILLARY(MARK);
                        ANCILLARY(QUEUE);
                        ANCILLARY(HATYPE);
                        ANCILLARY(RXHASH);
                        ANCILLARY(CPU);
                        ANCILLARY(ALU_XOR_X);
                        ANCILLARY(VLAN_TAG);
                        ANCILLARY(VLAN_TAG_PRESENT);
                        }
_______________________________________________
tcpdump-workers mailing list
tcpdump-workers@lists.tcpdump.org
https://lists.sandelman.ca/mailman/listinfo/tcpdump-workers
