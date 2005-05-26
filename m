From: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Subject: RE: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Thu, 26 May 2005 13:41:53 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E056F6B37@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <anton@samba.org>, <rende@cn.ibm.com>, <ganesh.venkatesan@gmail.com>,
        <herbert@gondor.apana.org.au>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, <jgarzik@pobox.com>,
        <wangjs@cn.ibm.com>, "Ronciak, John" <john.ronciak@intel.com>,
        <cdlwangl@cn.ibm.com>, <linuxppc64-dev@lists.linuxppc.org.sgi.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Andrew Morton" <akpm@osdl.org>, "Jian Jun He" <hejianj@cn.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew:

I already responded to this analysis before. In any case, here it is:

Later versions of e100 (3.4.8 for instance) includes a call to
netif_poll_disable in e100_down. This is supposed to wait and when it
returns we are guaranteed that e100_poll will no longer be called. In
addition, if there happens to be an interrupt, our call to
netif_rx_schedule() will not add our poll routine to the poll-list since
poll is disabled. So this race can never happen.

Ganesh.

>-----Original Message-----
>From: Andrew Morton [mailto:akpm@osdl.org]
>Sent: Thursday, May 26, 2005 1:31 PM
>To: Jian Jun He
>Cc: Venkatesan, Ganesh; anton@samba.org; rende@cn.ibm.com;
>ganesh.venkatesan@gmail.com; herbert@gondor.apana.org.au; Brandeburg,
>Jesse; jgarzik@pobox.com; wangjs@cn.ibm.com; Ronciak, John;
>cdlwangl@cn.ibm.com; linuxppc64-dev@lists.linuxppc.org.sgi.com;
>netdev@oss.sgi.com
>Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while
running
>rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
>
>Jian Jun He <hejianj@cn.ibm.com> wrote:
>>
>>  2. Download rhr2-rhel4-1.0-14a.noarch.rpm from rhn.redhat.com and
>install
>>  it on
>>  the test machine.
>>  3. Configure and run the rhr test via invoking redhat-ready.
>
>This is the problematic bit.
>
>- Please provide a full URL which can be used to obtain rhr.
>  rhn.redhat.com is subscription-based.
>
>- Please describe the hardware setup - surely the test requires at
least
>  two machines.  How are they configured?
>
>- Provide an exact transcript of the commands which are to be used.  Is
>  it just
>
>	redhat-ready
>
>  with no arguments?
>
>
>
>All that begin said, we already have a quite specific diagnosis via
code
>inspection, from Herbert:
>
>
>Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>
>> Andrew Morton <akpm@osdl.org> wrote:
>> >
>> > Might be a bug in the e100 driver, might not be.
>> >
>> > I assume this is the
>> >
>> >        BUG_ON(skb->list != NULL);
>>
>> It certainly is a bug in e100.
>>
>> e100_tx_timeout -> e100_down -> e100_rx_clean_list
>>
>> is racing against
>>
>> e100_poll -> e100_rx_clean -> e100_rx_indicate
>>
>> e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and
>> while it's being processed e100_rx_clean_list comes along and
>> frees it.
>>
>> From a quick check similar problems may exist in other drivers that
>> have lockless ->poll() functions with RX rings.
>
>Do the e100 maintainers agree with this diagnosis?  If so then more
testing
>isn't required at this stage - the next step is to fix the above bug,
no?
