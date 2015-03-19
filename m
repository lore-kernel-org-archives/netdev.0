From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2] filter: introduce SKF_AD_VLAN_TPID BPF extension
Date: Thu, 19 Mar 2015 09:08:35 -0700
Message-ID: <550AF483.8040202@plumgrid.com>
References: <1426763414-10091-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, Ralf Baechle <ralf@linux-mips.org>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34201 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbCSQIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:08:34 -0400
Received: by igcau2 with SMTP id au2so13542574igc.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 09:08:34 -0700 (PDT)
In-Reply-To: <1426763414-10091-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/19/15 4:10 AM, Michal Sekletar wrote:
> If vlan offloading takes place then vlan header is removed from frame
> and its contents, both vlan_tci and vlan_proto, is available to userspace via
> TPACKET interface. However, only vlan_tci can be used in BPF filters.
>
> This commit introduces new BPF extension. It makes possible to load value of
> vlan_proto (vlan TPID) to register A.

Agree with the idea, though we need to decide whether to do ntohs on
vlan_proto or not. Since right now your patch makes it consistent
on different architectures.

For arch where extended BPF jit is available the following:
 > +	case SKF_AD_OFF + SKF_AD_VLAN_TPID:
...
 > +		/* A = ntohs(A) [emitting a nop or swap16] */
 > +		*insn = BPF_ENDIAN(BPF_FROM_BE, BPF_REG_A, 16);

will make sure that it's doing ntohs,
whereas arm JIT is doing normal 16-bit load.
ppc can be both big and little, so PPC_LHZ_OFFS is incorrect.

Since it's a new field, I think it makes sense not to do ntohs at all.
Let bpf programs do htons(PROTO_CONSTANT), since it can be done at
compile time instead of run-time.
