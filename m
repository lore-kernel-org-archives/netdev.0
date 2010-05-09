From: Claus Regelmann <rgc@rgc1.inka.de>
Subject: error in arp.c for Token Ring (IEEE802_TR) and ...
Date: Mon, 10 May 2010 00:39:45 +0200
Message-ID: <4BE739B1.8040509@rgc1.inka.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from quechua.inka.de ([193.197.184.2]:34283 "EHLO mail.inka.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751801Ab0EIXBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 19:01:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello together,

with newer Kernels (my last one running without this error is 2.6.22.14),
I experieced the error described below two times with different systems (distributions).
I solved it for me, but I think this error has a more general reason and does not only
concern TR-networks. I'm not able to provide a general patch. Therefore I foreward
the message to you.

Regards
Claus Regelmann

-------- Original Message --------
Subject: Re: PCMCIA, IBMTR_CS, ARP-HW-TYPE
Date: Sun, 09 May 2010 02:52:43 +0200
From: Claus Regelmann <rgc@rgc1.inka.de>
Reply-To: LFS Developers Mailinglist <lfs-dev@linuxfromscratch.org>
To: LFS Developers Mailinglist <lfs-dev@linuxfromscratch.org>
References: <4ACBB8DD.2020405@rgc1.inka.de>

Hallo again,

installing OpenSuse 11.2 on desktop maschine with a TR-PCI card (driver olympic),
I reexperienced the problem described below. I dived further into the problem
-- almost by trial and error -- and found that the error is in
'.../net/ipv4/arp.c' in the function 'arp_create'.
--------------------(kernel 2.6.30.4)--------------------------------
          /*
           *      Exceptions everywhere. AX.25 uses the AX.25 PID value not the
           *      DIX code for the protocol. Make these device structure fields.
           */
          printk(KERN_WARNING "arp_create hwtype=%d %d\n",dev->type,ARPHRD_IEEE802_TR); <<my test code
          switch (dev->type) {
          default:
                  arp->ar_hrd = htons(dev->type);
                  arp->ar_pro = htons(ETH_P_IP);
                  break;

#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
          case ARPHRD_AX25:
                  arp->ar_hrd = htons(ARPHRD_AX25);
                  arp->ar_pro = htons(AX25_P_IP);
                  break;

#if defined(CONFIG_NETROM) || defined(CONFIG_NETROM_MODULE)
          case ARPHRD_NETROM:
                  arp->ar_hrd = htons(ARPHRD_NETROM);
                  arp->ar_pro = htons(AX25_P_IP);
                  break;
#endif
#endif

#ifdef CONFIG_FDDI
          case ARPHRD_FDDI:
                  arp->ar_hrd = htons(ARPHRD_ETHER);
                  arp->ar_pro = htons(ETH_P_IP);
                  break;
#endif
// #ifdef CONFIG_TR    <===============================
          case ARPHRD_IEEE802_TR:
              printk(KERN_WARNING "arp_create: IEEE802_TR\n");
                  arp->ar_hrd = htons(ARPHRD_IEEE802);
                  arp->ar_pro = htons(ETH_P_IP);
                  break;
// #endif             <==================================
}

          arp->ar_hln = dev->addr_len;
          arp->ar_pln = 4;


After commenting the cond. compilation of CONFIG_TR all works.

So the question is why CONFIG_TR is undefined allthought .config says:
...
# CONFIG_NETDEV_1000 is not set
# CONFIG_NETDEV_10000 is not set
CONFIG_TR=m
# CONFIG_IBMOL is not set
# CONFIG_IBMLS is not set
...

Claus
--------------------------------------------------------------
Claus Regelmann wrote:
> I forward this problem to the lfs-dev-list now.
> If anybody can give me a hint where to start searching the problem
> in the kernel code, I'll try to fix it.
> 
> Claus
> ------------------------------------------------------------------
> -------- Original Message --------
> Subject: Re: PCMCIA, IBMTR_CS, ARP-HW-TYPE
> Date: Sat, 3 Oct 2009 10:29:34 -0800
> From: ALIP BUDIANTO <rabbit8888@gmail.com>
> Reply-To: BLFS Support List <blfs-support@linuxfromscratch.org>
> To: BLFS Support List <blfs-support@linuxfromscratch.org>
> References: <e1d873ab0910030309u2adafd7cpbc8c044e99fc08cf@mail.gmail.com>	<4AC796EE.5070201@rgc1.inka.de>
> 
> If its the kernel mabye yes.
> If its on only BLFS stay here unlesss the LFS build affects BLFS.
> 
> On Sat, Oct 3, 2009 at 10:24 AM, Claus Regelmann <rgc@rgc1.inka.de> wrote:
>> Richard Melville wrote:
>>>
>>>     Claus Regelmann said:-
>>>
>>>
>>>
>>>     I recently finished installing LFS 6.5 on my old Laptop (IBM-T21).
>>>     I added SYSFSUTILS-2.1.0 and PCMCIAUTILS-0.15, put the TR card in,
>>>     called pcmcia-socket-startup, found the tr0 interface, configured
>>>     tr0, and tried to ping another machine in my network.
>>>     -- no response --
>>>     I continued investigating the situation with wireshark, and found
>>>     that my T21 sends ARP requests and responces with an unknown HW type
>>>     of 0x320.The correct HW type should be 0x06.
>>>
>>>     Where does the wrong HW type come from??
>>>     'cat /sys/bus/pcmcia/devices/0.0/net/tr0/type' displays 800, which
>>>     is equal to 0x320
>>>
>>> Do you have all the correct drivers configured in the kernel?
>>>
>>> Richard
>>>
>> Yes, all modules are loaded and the link layer is running. The problem
>> comes form the arp traffic where my T21 uses a wrong ARPHRD value.
>> But I found a qnd work arround that works for me:
>> ---------------------------------- patch for ibmtr_cs.c -------
>>    /*  Set up the Token-Ring Controller Configuration Register and
>>         turn on the card.  Check the "Local Area Network Credit Card
>>         Adapters Technical Reference"  SC30-3585 for this info.  */
>>     ibmtr_hw_setup(dev, mmiobase);
>>  -> dev->type=0x06;
>>  -> printk (KERN_INFO " ibmtr_cs after HW setup: dev->type=%d\n",dev->type);
>>
>>     link->dev_node = &info->node;
>> ----------------------------------------------------------------
>> But this patch is not a real fix!
>>
>> if you lock into include/linux/if_arp.h you will find
>> #define ARPHRD_IEEE802  6
>> ... and ...
>> #define ARPHRD_IEEE802_TR 800
>>
>> I've several desktops in my net, the oldest one has even an ISA adapter (module ibmtr),
>> the others have IBM-PCI adapter (module olympic), and all these machines use ARPHRD_IEEE802.
>>
>> So the remaining question is: why does 'ibmtr_cs' use ARPHRD_IEEE802_TR.
>>
>> Shall I submit this problem to the LFS-DEV mailing list?
>>
>> Claus
>>
>> P.S.: I also tested a very old PS/2 micro channel machine. It also uses ARPHRD_IEEE802.
>> --
>> http://linuxfromscratch.org/mailman/listinfo/blfs-support
>> FAQ: http://www.linuxfromscratch.org/blfs/faq.html
>> Unsubscribe: See the above information page
>>

-- 
http://linuxfromscratch.org/mailman/listinfo/lfs-dev
FAQ: http://www.linuxfromscratch.org/faq/
Unsubscribe: See the above information page

