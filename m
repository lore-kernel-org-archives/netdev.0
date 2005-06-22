From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] Micro optimization in eth_header()
Date: Wed, 22 Jun 2005 11:31:43 +0300
Message-ID: <200506221131.43049.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_vHSuC2OnpQh1+22"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_vHSuC2OnpQh1+22
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Compile tested only.
--
vda

--Boundary-00=_vHSuC2OnpQh1+22
Content-Type: text/x-diff;
  charset="koi8-r";
  name="eth.c.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="eth.c.diff"

Micro optimization in eth_header().
Changes in asm code (new on the right):

...
  50: shl    $0x8,%edx                     50: shl    $0x8,%edx
  53: shr    $0x8,%eax                     53: shr    $0x8,%eax
  56: or     %eax,%edx                     56: or     %eax,%edx
  58: mov    %dx,0xc(%ebx)              +  58: test   %esi,%esi
  5c: mov    0xc(%ebp),%edx             +  5a: mov    %dx,0xc(%ebx)
  5f: test   %esi,%esi                  +  5e: jne    69 <eth_header+0x69>
  61: mov    0xb0(%edx),%al             +  60: mov    0xc(%ebp),%esi
  67: je     71 <eth_header+0x71>       +  63: add    $0x90,%esi
  69: movzbl %al,%eax                   +  69: mov    0xc(%ebp),%edx
  6c: lea    0x6(%ebx),%edi             +  6c: movzbl 0xb0(%edx),%eax
  6f: jmp    80 <eth_header+0x80>       +  73: mov    %eax,%ecx
  71: mov    0xc(%ebp),%edx             +  75: lea    0x6(%ebx),%edi
  74: movzbl %al,%eax                   +  78: shr    $0x2,%ecx
  77: lea    0x6(%ebx),%edi             +  7b: repz movsl %ds:(%esi),%es:(%edi)
  7a: lea    0x90(%edx),%esi            +  7d: mov    %eax,%ecx
  80: mov    %eax,%ecx                  +  7f: and    $0x3,%ecx
  82: shr    $0x2,%ecx                  +  82: je     86 <eth_header+0x86>
  85: repz movsl %ds:(%esi),%es:(%edi)  +  84: repz movsb %ds:(%esi),%es:(%edi)
  87: mov    %eax,%ecx                  +  86: testb  $0x88,0x58(%edx)
  89: and    $0x3,%ecx                  +  8a: je     b1 <eth_header+0xb1>
  8c: je     90 <eth_header+0x90>       +  8c: movzbl 0xb0(%edx),%esi
  8e: repz movsb %ds:(%esi),%es:(%edi)  +  93: mov    %esi,%ecx
  90: mov    0xc(%ebp),%eax             +  95: shr    $0x2,%ecx
  93: testb  $0x88,0x58(%eax)           +  98: mov    %ebx,%edi
  97: je     bc <eth_header+0xbc>       +  9a: xor    %eax,%eax
  99: movzbl 0xb0(%eax),%edx            +  9c: mov    %esi,%edx
  a0: mov    %edx,%ecx                  +  9e: repz stos %eax,%es:(%edi)
  a2: xor    %eax,%eax
  a4: shr    $0x2,%ecx
  a7: mov    %ebx,%edi
  a9: repz stos %eax,%es:(%edi)
..

--- linux-2.6.12-rc2.src/net/ethernet/eth.c.orig	Thu Mar  3 09:31:21 2005
+++ linux-2.6.12-rc2.src/net/ethernet/eth.c	Wed Jun 22 11:13:54 2005
@@ -92,10 +92,9 @@ int eth_header(struct sk_buff *skb, stru
 	 *	Set the source hardware address. 
 	 */
 	 
-	if(saddr)
-		memcpy(eth->h_source,saddr,dev->addr_len);
-	else
-		memcpy(eth->h_source,dev->dev_addr,dev->addr_len);
+	if(!saddr)
+		saddr = dev->dev_addr;
+	memcpy(eth->h_source,saddr,dev->addr_len);
 
 	/*
 	 *	Anyway, the loopback-device should never use this function... 

--Boundary-00=_vHSuC2OnpQh1+22--
