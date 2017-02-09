From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 1/2] bpf: Save original ebpf instructions
Date: Wed, 8 Feb 2017 18:28:51 -0700
Message-ID: <d6fe10c7-2275-43a3-715e-f76aafdec328@cumulusnetworks.com>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
 <1486154303-32278-2-git-send-email-dsa@cumulusnetworks.com>
 <5894F19A.60305@iogearbox.net>
 <34456681-46d1-0761-3b61-4e308f363126@cumulusnetworks.com>
 <ddfeb9be-31a7-a2ba-abe2-55a1f90cc548@6wind.com>
 <5898847B.2060400@iogearbox.net>
 <20170206192114.GA54756@ast-mbp.thefacebook.com>
 <83e2bd44-fbe0-38a5-f080-3042572d8a64@cumulusnetworks.com>
 <589AF867.3020009@iogearbox.net>
 <c19a41f5-7737-d971-67e0-919276b47b95@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Quentin Monnet <quentin.monnet@6wind.com>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36149 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751046AbdBIClM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 21:41:12 -0500
Received: by mail-pg0-f52.google.com with SMTP id v184so53196439pgv.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 18:41:12 -0800 (PST)
In-Reply-To: <c19a41f5-7737-d971-67e0-919276b47b95@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/17 12:40 PM, David Ahern wrote:
> On 2/8/17 3:52 AM, Daniel Borkmann wrote:
>> for cBPF dumps it looks like this in ss. Can you tell me what these
>> 11 insns do? Likely you can, but can a normal admin?
>>
>> # ss -0 -b
>> Netid  Recv-Q Send-Q                                       Local
>> Address:Port                                                        Peer
>> Address:Port
>> p_raw  0      0                                                       
>> *:em1                                                                *
>>     bpf filter (11):  0x28 0 0 12, 0x15 0 8 2048, 0x30 0 0 23, 0x15 0 6
>> 17, 0x28 0 0 20, 0x45 4 0 8191, 0xb1 0 0 14, 0x48 0 0 16, 0x15 0 1 68,
>> 0x06 0 0 4294967295, 0x06 0 0 0,
> 
...

> 
> It's not rocket science. We should be able to write tools that do the
> same for bpf as objdump does for assembly. It is a matter of someone
> having the need and taking the initiative. BTW, the bpf option was added

Just a couple of hours of hacking this afternoon and leveraging some of
the verifier code in the kernel, the above bpf filter in more human
friendly terms:

BPF_LD  | BPF_ABS  | BPF_H       0xc    :  val = *(u16 *)skb[12]
BPF_JMP | BPF_JEQ  | BPF_K  0  8 0x800  :  if !(val == 0x800) goto pc+8
BPF_LD  | BPF_ABS  | BPF_B       0x17   :  val = *(u8 *)skb[23]
BPF_JMP | BPF_JEQ  | BPF_K  0  6 0x11   :  if !(val == 0x11) goto pc+6
BPF_LD  | BPF_ABS  | BPF_H       0x14   :  val = *(u16 *)skb[20]
BPF_JMP | BPF_JSET | BPF_K  4  0 0x1fff :  if ((val & 0x1fff) != 0) goto
pc+4
BPF_LDX | BPF_MSH  | BPF_B       0xe    :
BPF_LD  | BPF_IND  | BPF_H       0x10   :  val = *(u16 *)skb[16]
BPF_JMP | BPF_JEQ  | BPF_K  0  1 0x44   :  if !(val == 0x44) goto pc+1
BPF_RET ffffffff                        :  ret ffffffff
BPF_RET 0                               :  ret 0

(long lines so I chopped the reprint of the hex on the left)

That said, verifying that the program attached to a cgroup is correct
for a VRF does not require it to be pretty printed or viewed by humans.
I can automate the checks on namespace id and and device index.
