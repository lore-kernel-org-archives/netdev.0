From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net-next] net: stmmac: set total length of the packet to
 be transmitted in TDES3
Date: Tue, 11 Apr 2017 11:10:06 +0200
Message-ID: <cfa7d7e4-621c-5b64-f707-51b0fa77ece9@axis.com>
References: <20170410183329.28847-1-niklass@axis.com>
 <8e26bc0b-62eb-da22-8144-7cae2efe8095@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8e26bc0b-62eb-da22-8144-7cae2efe8095@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/11/2017 10:48 AM, Joao Pinto wrote:
> 
> Hi Niklas,
> 
> Às 7:33 PM de 4/10/2017, Niklas Cassel escreveu:
>> From: Niklas Cassel <niklas.cassel@axis.com>
>>
>> Field FL/TPL in register TDES3 is not correctly set on GMAC4.
>> TX appears to be functional on GMAC 4.10a even if this field is not set,
>> however, to avoid relying on undefined behavior, set the length in TDES3.
>>
>> The field has a different meaning depending on if the TSE bit in TDES3
>> is set or not (TSO). However, regardless of the TSE bit, the field is
>> not optional. The field is already set correctly when the TSE bit is set.
>>
>> Since there is no limit for the number of descriptors that can be
>> used for a single packet, the field should be set to the sum of
>> the buffers contained in:
>> [<desc with First Descriptor bit set> ... <desc n> ...
>> <desc with Last Descriptor bit set>], which should be equal to skb->len.
>>
>> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
> 
> Sounds fine to me. Did you check for performance improvement? Thanks.
> 

Hello Joao,

I could not see any difference with 1 TCP stream in iperf3

Without the patch:
# ./iperf3-armhf -c 192.168.0.1
Connecting to host 192.168.0.1, port 5201
[  4] local 192.168.0.105 port 51878 connected to 192.168.0.1 port 5201
[   23.486426] random: fast init done
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  61.7 MBytes   517 Mbits/sec    0    294 KBytes       
[  4]   1.00-2.00   sec  61.3 MBytes   515 Mbits/sec    0    294 KBytes       
[   26.043850] random: crng init done
[  4]   2.00-3.00   sec  61.4 MBytes   515 Mbits/sec    0    294 KBytes       
[  4]   3.00-4.00   sec  61.0 MBytes   512 Mbits/sec    0    294 KBytes       
[  4]   4.00-5.00   sec  61.5 MBytes   516 Mbits/sec    0    294 KBytes       
[  4]   5.00-6.00   sec  61.2 MBytes   514 Mbits/sec    0    294 KBytes       
[  4]   6.00-7.00   sec  61.5 MBytes   516 Mbits/sec    0    294 KBytes       
[  4]   7.00-8.00   sec  61.4 MBytes   515 Mbits/sec    0    294 KBytes       
[  4]   8.00-9.00   sec  61.2 MBytes   514 Mbits/sec    0    294 KBytes       
[  4]   9.00-10.00  sec  61.3 MBytes   514 Mbits/sec    0    294 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   614 MBytes   515 Mbits/sec    0             sender
[  4]   0.00-10.00  sec   613 MBytes   514 Mbits/sec                  receiver


With the patch:
# ./iperf3-armhf -c 192.168.0.1
Connecting to host 192.168.0.1, port 5201
[  4] local 192.168.0.105 port 37696 connected to 192.168.0.1 port 5201
[   85.266262] random: fast init done
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  62.1 MBytes   520 Mbits/sec    0    288 KBytes       
[  4]   1.00-2.00   sec  61.0 MBytes   512 Mbits/sec    0    288 KBytes       
[   87.782547] random: crng init done
[  4]   2.00-3.00   sec  61.3 MBytes   515 Mbits/sec    0    300 KBytes       
[  4]   3.00-4.00   sec  61.1 MBytes   512 Mbits/sec    0    300 KBytes       
[  4]   4.00-5.00   sec  61.4 MBytes   515 Mbits/sec    0    300 KBytes       
[  4]   5.00-6.00   sec  61.1 MBytes   513 Mbits/sec    0    300 KBytes       
[  4]   6.00-7.00   sec  61.1 MBytes   513 Mbits/sec    0    300 KBytes       
[  4]   7.00-8.00   sec  61.6 MBytes   517 Mbits/sec    0    300 KBytes       
[  4]   8.00-9.00   sec  61.3 MBytes   515 Mbits/sec    0    300 KBytes       
[  4]   9.00-10.00  sec  61.6 MBytes   517 Mbits/sec    0    300 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   614 MBytes   515 Mbits/sec    0             sender
[  4]   0.00-10.00  sec   613 MBytes   514 Mbits/sec                  receiver


Note that the results above are with TSO off.
With TSO on, I get 921 Mbps.
However, the patch should not affect the case where TSO is on.


Regards,
Niklas
