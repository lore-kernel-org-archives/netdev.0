From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver in 2.6.6
Date: Sat, 29 May 2004 01:07:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529010751.A8207@electric-eye.fr.zoreil.com>
References: <20040525230831.4747005f.ray_cole@earthlink.net> <20040525231140.1325daa7.ray_cole@earthlink.net> <20040526055841.GH3330@ruslug.rutgers.edu> <20040526133645.B32639@electric-eye.fr.zoreil.com> <20040526070014.17ee9486.ray_cole@earthlink.net> <20040526161508.A3368@electric-eye.fr.zoreil.com> <20040526191528.54f4af59.ray_cole@earthlink.net> <20040526205324.0913df99.ray_cole@earthlink.net> <20040526221742.393e626d.ray_cole@earthlink.net> <20040526230632.26c4e2e5.ray_cole@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ray Cole <ray_cole@earthlink.net>
Content-Disposition: inline
In-Reply-To: <20040526230632.26c4e2e5.ray_cole@earthlink.net>; from ray_cole@earthlink.net on Wed, May 26, 2004 at 11:06:32PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ray Cole <ray_cole@earthlink.net> :
> It looks like it is most definately a gcc 2.95.3 issue.  I turned off
> optimization (appended -O0 to the compiler command line) and the 'bad' way
> gives the proper result.  -O1, on the other hand, gives an incorrect result.

I have checked the modules you sent me and  the generated code is wrong
(relevant code below). You should upgrade your venerable 2.95.3 compiler.


[...]
00001750 <rtl8169_start_xmit>:
    1750:	83 ec 08             	sub    $0x8,%esp
    1753:	55                   	push   %ebp
    1754:	57                   	push   %edi
    1755:	56                   	push   %esi
    1756:	53                   	push   %ebx
    1757:	8b 4c 24 1c          	mov    0x1c(%esp,1),%ecx

-> %ecx = skb (will not change)

    175b:	8b 7c 24 20          	mov    0x20(%esp,1),%edi
    175f:	8b 44 24 20          	mov    0x20(%esp,1),%eax
    1763:	8b 54 24 20          	mov    0x20(%esp,1),%edx

-> %edx = %eax = %edi = dev

    1767:	81 c7 20 02 00 00    	add    $0x220,%edi

-> %edi = tp

    176d:	8b 80 20 02 00 00    	mov    0x220(%eax),%eax

-> %eax = ioaddr

    1773:	89 44 24 14          	mov    %eax,0x14(%esp,1)
    1777:	8b aa 98 02 00 00    	mov    0x298(%edx),%ebp

-> %ebp = tp->cur_tx

    177d:	8b 59 64             	mov    0x64(%ecx),%ebx

-> %ebx = skb->len

    1780:	83 e5 3f             	and    $0x3f,%ebp

-> %ebp = entry = tp->cur_tx % NUM_TX_DESC 

    1783:	83 fb 3b             	cmp    $0x3b,%ebx

-> ETH_ZLEN test

    1786:	77 29                	ja     17b1 <rtl8169_start_xmit+0x61>
[...]
    17b1:	fa                   	cli    
    17b2:	b8 00 e0 ff ff       	mov    $0xffffe000,%eax
    17b7:	21 e0                	and    %esp,%eax
    17b9:	ff 40 14             	incl   0x14(%eax)
    17bc:	8b 87 84 00 00 00    	mov    0x84(%edi),%eax

-> %eax = tp->TxDesc

    17c2:	89 ee                	mov    %ebp,%esi
    17c4:	c1 e6 04             	shl    $0x4,%esi

-> %esi = entry * sizeof(TxDesc) 

    17c7:	8b 04 30             	mov    (%eax,%esi,1),%eax
    17ca:	25 00 00 00 80       	and    $0x80000000,%eax

-> %eax = tp->TxDesc[entry].status & OWNbit

    17cf:	89 44 24 10          	mov    %eax,0x10(%esp,1)
    17d3:	0f 85 a7 00 00 00    	jne    1880 <rtl8169_start_xmit+0x130>

-> Let's assume host cpu owns the descriptor and move on

    17d9:	8b 91 90 00 00 00    	mov    0x90(%ecx),%edx
    17df:	8d 87 94 04 00 00    	lea    0x494(%edi),%eax
    17e5:	89 0c a8             	mov    %ecx,(%eax,%ebp,4)

-> tp->Tx_skbuff[entry] = skb;

    17e8:	8b 87 84 00 00 00    	mov    0x84(%edi),%eax

-> %eax = tp->TxDesc

    17ee:	81 c2 00 00 00 40    	add    $0x40000000,%edx
    17f4:	89 54 30 08          	mov    %edx,0x8(%eax,%esi,1)
    17f8:	c7 44 30 0c 00 00 00 	movl   $0x0,0xc(%eax,%esi,1)
    17ff:	00 

-> tp->TxDescArray[entry].addr = cpu_to_le64(mapping);

    1800:	8b 97 84 00 00 00    	mov    0x84(%edi),%edx

-> %edx = tp->TxDesc

    1806:	89 d8                	mov    %ebx,%eax
    1808:	0d 00 00 00 f0       	or     $0xf0000000,%eax

-> %eax = OWNbit | FSbit | LSbit | EORbit | skb->len

    180d:	81 cb 00 00 00 b0    	or     $0xb0000000,%ebx

-> %ebx = OWNbit | FSbit | LSbit | skb->len

    1813:	83 fd ff             	cmp    $0xffffffff,%ebp

-> ???
   Bogus test against %ebp (= entry). It will produce the expected
   result until the end of ring is reached. Then it will forgot to
   set the end of ring flag in the descriptor and the story ends.

    1816:	0f 45 c3             	cmovne %ebx,%eax
    1819:	89 04 32             	mov    %eax,(%edx,%esi,1)

-> tp->TxDesc[entry].status = ...

    181c:	8b 44 24 14          	mov    0x14(%esp,1),%eax
    1820:	c6 40 38 40          	movb   $0x40,0x38(%eax)
    1824:	a1 00 00 00 00       	mov    0x0,%eax
    1829:	8b 54 24 20          	mov    0x20(%esp,1),%edx
    182d:	89 42 4c             	mov    %eax,0x4c(%edx)
    1830:	8b 47 78             	mov    0x78(%edi),%eax
    1833:	8d 50 01             	lea    0x1(%eax),%edx
    1836:	89 57 78             	mov    %edx,0x78(%edi)
    1839:	83 c0 c1             	add    $0xffffffc1,%eax
    183c:	3b 87 80 00 00 00    	cmp    0x80(%edi),%eax
    1842:	75 1c                	jne    1860 <rtl8169_start_xmit+0x110>
    1844:	68 67 07 00 00       	push   $0x767
    1849:	e8 fc ff ff ff       	call   184a <rtl8169_start_xmit+0xfa>
    184e:	83 c4 04             	add    $0x4,%esp
    1851:	8b 54 24 10          	mov    0x10(%esp,1),%edx
    1855:	8b 44 24 20          	mov    0x20(%esp,1),%eax
    1859:	0f ab 50 24          	bts    %edx,0x24(%eax)
    185d:	8d 76 00             	lea    0x0(%esi),%esi
    1860:	fb                   	sti    
[...]

--
Ueimor
