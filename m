From: ByeoungWook Kim <quddnr145@gmail.com>
Subject: Re: [PATCH 1/2] rtlwifi: Fix improve function 'rtl_addr_delay()' in core.c
Date: Thu, 4 Feb 2016 02:49:28 +0900
Message-ID: <CAOxTRzpO4mx361GqA+W39bxSfbOCaiLw320S-aph1v1OGJ0FYw@mail.gmail.com>
References: <20160203015953.GA13562@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD5486@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Larry.Finger@lwfinger.net" <Larry.Finger@lwfinger.net>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"chaoming_li@realsil.com.cn" <chaoming_li@realsil.com.cn>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD5486@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

2016-02-03 23:41 GMT+09:00 David Laight <David.Laight@aculab.com>:
> From: Byeoungwook Kim
>> Sent: 03 February 2016 02:00
>> Conditional codes in rtl_addr_delay() were improved in readability and
>> performance by using switch codes.
>> ...
>>  void rtl_addr_delay(u32 addr)
>>  {
>> -     if (addr == 0xfe)
>> +     switch (addr) {
>> +     case 0xfe:
>>               mdelay(50);
>> -     else if (addr == 0xfd)
>> +             break;
>> +     case 0xfd:
>>               mdelay(5);
>> -     else if (addr == 0xfc)
>> +             break;
>> +     case 0xfc:
>>               mdelay(1);
>> -     else if (addr == 0xfb)
>> +             break;
>> +     case 0xfb:
>>               udelay(50);
>> -     else if (addr == 0xfa)
>> +             break;
>> +     case 0xfa:
>>               udelay(5);
>> -     else if (addr == 0xf9)
>> +             break;
>> +     case 0xf9:
>>               udelay(1);
>> +             break;
>> +     };
>
> Straight 'performance' can't matter here, not with mdelay(50)!
> The most likely effect is from speeding up the 'don't delay' path
> and reducing the number of conditionals (and hence accuracy of) udelay(1).
> Reversing the if-chain might be better still.
>

I agree with your assists about "The most likely effect is from
speeding up the 'don't delay' path and reducing the number of
conditionals (and hence accuracy of) udelay(1).".

I converted to assembly codes like next line from conditionals.

---

  if (addr == 0xf9)
00951445  cmp        dword ptr [addr],0F9h
0095144C  jne        main+35h (0951455h)
      a();
0095144E  call        a (09510EBh)
00951453  jmp        main+83h (09514A3h)
  else if (addr == 0xfa)
00951455  cmp        dword ptr [addr],0FAh
0095145C  jne        main+45h (0951465h)
      a();
0095145E  call        a (09510EBh)
00951463  jmp        main+83h (09514A3h)
  else if (addr == 0xfb)
00951465  cmp        dword ptr [addr],0FBh
0095146C  jne        main+55h (0951475h)
      a();
0095146E  call        a (09510EBh)
00951473  jmp        main+83h (09514A3h)
  else if (addr == 0xfc)
00951475  cmp        dword ptr [addr],0FCh
0095147C  jne        main+65h (0951485h)
      b();
0095147E  call        b (09510E6h)
00951483  jmp        main+83h (09514A3h)
  else if (addr == 0xfd)
00951485  cmp        dword ptr [addr],0FDh
0095148C  jne        main+75h (0951495h)
      b();
0095148E  call        b (09510E6h)
00951493  jmp        main+83h (09514A3h)
  else if (addr == 0xfe)
00951495  cmp        dword ptr [addr],0FEh
0095149C  jne        main+83h (09514A3h)
      b();
0095149E  call        b (09510E6h)

---

if the addr value was 0xfe, Big-O-notation is O(1).
but if the addr value was 0xf9, Big-O-notation is O(n).

2016-02-03 23:41 GMT+09:00 David Laight <David.Laight@aculab.com>:
> From: Byeoungwook Kim
>> Sent: 03 February 2016 02:00
>> Conditional codes in rtl_addr_delay() were improved in readability and
>> performance by using switch codes.
>
> I'd like to see the performance data :-)

I used switch codes to solve of this problem.

If the addr variable was increment consecutive, switch codes is able
to use branch table for optimize.
so I converted to assembly codes like next line from same codes about my patch.

 switch (addr)
011C1445  mov        eax,dword ptr [addr]
011C1448  mov        dword ptr [ebp-0D0h],eax
011C144E  mov        ecx,dword ptr [ebp-0D0h]
011C1454  sub        ecx,0F9h
011C145A  mov        dword ptr [ebp-0D0h],ecx
011C1460  cmp        dword ptr [ebp-0D0h],5
011C1467  ja          $LN6+28h (011C149Eh)
011C1469  mov        edx,dword ptr [ebp-0D0h]
011C146F  jmp        dword ptr [edx*4+11C14B4h]
  {
  case 0xf9: a(); break;
011C1476  call        a (011C10EBh)
011C147B  jmp        $LN6+28h (011C149Eh)
  case 0xfa: a(); break;
011C147D  call        a (011C10EBh)
011C1482  jmp        $LN6+28h (011C149Eh)
  case 0xfb: a(); break;
011C1484  call        a (011C10EBh)
011C1489  jmp        $LN6+28h (011C149Eh)
  case 0xfc: b(); break;
011C148B  call        b (011C10E6h)
011C1490  jmp        $LN6+28h (011C149Eh)
  case 0xfd: b(); break;
011C1492  call        b (011C10E6h)
011C1497  jmp        $LN6+28h (011C149Eh)
  case 0xfe: b(); break;
011C1499  call        b (011C10E6h)
  }

===[[branch table]]===
011C14B4     011C1476h
011C14B8     011C147Dh
011C14BC     011C1484h
011C14C0     011C148Bh
011C14C4     011C1492h
011C14C8     011C1499h

So conditional codes into rtl_addr_delay() can improve to readability
and performance that used switch codes.

Regards,
Byeoungwook.
